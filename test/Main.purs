module Test.Main where

import Prelude
import Control.Monad.Aff (Aff, attempt, launchAff)
import Control.Monad.Aff.Console (CONSOLE, logShow)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (log) as Eff
import Control.Monad.Eff.Exception (Error, EXCEPTION)
import Data.Either (Either(..))
import Data.Foreign (Foreign, toForeign)
import Data.Foreign.Class (readProp)
import Data.Int.Bits (xor)
import Data.Maybe (Maybe(..))
import Debug.Trace (traceAny)
import MTProto (ApiManager, newApiManager, mtpInvokeApi, MANAGER, MTPROTO)

newManager :: forall e. Eff (manager :: MANAGER | e) ApiManager
newManager =
  newApiManager Nothing

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
