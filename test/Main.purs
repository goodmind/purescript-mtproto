module Test.Main where

import Prelude
import Control.Monad.Aff (Aff, attempt, launchAff)
import Control.Monad.Aff.Console (CONSOLE, logShow)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (log) as Eff
import Control.Monad.Eff.Exception (Error, EXCEPTION)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Debug.Trace (traceAny)
import MTProto (ApiManager, MANAGER, MTPROTO, mtpInvokeApi, newApiManager)

{--
newAsyncStorage :: AsyncStorage
newAsyncStorage = Just $ NewAsyncStorage { get, set, remove, clear }
  where
    get keys = Nothing
    set obj = Nothing
    remove keys = Nothing
    clear = Nothing
--}

newManager :: forall e. Eff (manager :: MANAGER | e) ApiManager
newManager = do
  newApiManager config
  where
    config = Just {
      api : Nothing,
      app : Just {
        debug : Just true,
        storage : Nothing -- newAsyncStorage
      },
      server : Nothing,
      schema : Nothing,
      mtSchema : Nothing
    }

getConfig :: forall e a. ApiManager -> (Aff (mtproto :: MTPROTO | e) (Either Error a))
getConfig = 
  mtpInvokeApi "help.getConfig" {} { createNetworker: true } >>> attempt

logResponse :: forall e. (Either Error String) -> (Aff (console :: CONSOLE | e) Unit)
logResponse (Left error) = logShow error
logResponse (Right r) = traceAny r \x -> logShow "ok"

main :: Eff (err :: EXCEPTION, console :: CONSOLE, manager :: MANAGER, mtproto :: MTPROTO) Unit
main = do
  Eff.log "Testing MTProto bindings"
  manager <- newManager
  void $ launchAff $ getConfig manager >>= logResponse
