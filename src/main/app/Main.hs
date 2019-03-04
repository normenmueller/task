{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Control.Monad         ((>=>))
import qualified Data.ByteString.Char8 as BS
import           Data.HashMap.Strict   ((!))
import qualified Data.HashMap.Strict   as M
import           Data.List.Split       as LS
import qualified Data.Text             as T
import           Data.Yaml
import           System.Environment

main :: IO ()
main = do
    args <- getArgs
    case args of
        [src, tgt] -> slurp >=> return . transform >=> flush tgt $ src
        _          -> error "Synopsis: task <source> <target>"

slurp :: FilePath -> IO Value
slurp f = do
    e <- BS.readFile f
    case decode' e of
        Left err  -> stderr err
        Right val -> return val
  where
    decode' :: BS.ByteString -> Either ParseException Value
    decode' = decodeEither'
    stderr :: ParseException -> IO a
    stderr = error . prettyPrintParseException

flush :: FilePath -> Value -> IO ()
flush = encodeFile

transform :: Value -> Value
transform = fltsch

{- Transformers -}

-- | Flatten schemas, i.e., resolve all references within schemas.
fltsch :: Value -> Value
fltsch (Object o) =
    case M.lookup "schemas" o of
        Just v@(Object ss) -> Object $ M.insert "schemas" (resref v ss) o
        _                  -> Object $ fltsch <$> o
fltsch (Array a) = Array $ fltsch <$> a
fltsch v = v

{- Helpers -}

resref :: Value -> Object -> Value
resref (Object o) d =
    case M.lookup "$ref" o of
        Just v@(String r) -> resref (d ! ref r) d
        _ -> Object $ flip resref d <$> o
resref v _ = v

ref :: T.Text -> T.Text
ref = T.pack . last . LS.endBy "/" . T.unpack

at :: T.Text -> Value -> Maybe Value
at p = at' (T.pack <$> (tail . LS.endBy "/" . T.unpack $ p))

at' :: [T.Text] -> Value -> Maybe Value
at' [] v              = return v
at' (p:ps) (Object o) = M.lookup p o >>= at' ps
at' _ _               = Nothing
