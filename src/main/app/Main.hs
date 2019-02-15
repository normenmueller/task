module Main where

import           Control.Monad
import           Data.Aeson
import qualified Data.ByteString.Char8 as BS
import qualified Data.Yaml             as Y
import qualified Data.Yaml.Pretty      as Y
import           GHC.Generics
import           System.Environment

main :: IO ()
main = do
    args <- getArgs
    case args of
        [inp, out] -> flush out . tweak <=< slurp $ inp
        _          -> error "Synopsis: task <in> <out>"

slurp :: FilePath -> IO Value
slurp f = do
    enc <- BS.readFile f
    case (Y.decodeEither' enc :: Either Y.ParseException Value) of
        Left e -> error . Y.prettyPrintParseException $ e
        Right v -> return v

flush :: FilePath -> Value -> IO ()
flush = Y.encodeFile

tweak :: Value -> Value
tweak = id
