module MTProto where
  
import Prelude
import Control.Promise
import Data.Maybe (Maybe(..))
import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Data.Foreign (Foreign)
import Data.Foreign.NullOrUndefined (NullOrUndefined)
import Data.Function.Uncurried (Fn4, Fn3, runFn3, runFn4)

type MTProtoEffects e = (mtproto :: MTPROTO | e)

foreign import data Schema :: *
foreign import data MtSchema :: *
foreign import data AsyncStorage :: *
foreign import data ApiManager :: *

instance showApiManager :: Show ApiManager where
  show _ = "ApiManager"

foreign import data MANAGER :: !
foreign import data MTPROTO :: !

type ServerConfig =
  { dev      :: NullOrUndefined Boolean,
    webogram :: NullOrUndefined Boolean
  }

type AppConfig =
  { debug   :: NullOrUndefined Boolean,
    storage :: NullOrUndefined AsyncStorage
  }

type ApiConfig =
  { invokeWithLayer :: NullOrUndefined Number,
    layer           :: NullOrUndefined Number,
    initConnection  :: NullOrUndefined Number,
    api_id          :: NullOrUndefined String,
    device_model    :: NullOrUndefined String,
    system_version  :: NullOrUndefined String,
    app_version     :: NullOrUndefined String,
    lang_code       :: NullOrUndefined String
  }

type Config = 
  { server :: NullOrUndefined ServerConfig,
    api :: NullOrUndefined ApiConfig,
    app :: NullOrUndefined AppConfig,
    schema :: NullOrUndefined Schema,
    mtSchema :: NullOrUndefined MtSchema
  }

foreign import _newApiManager :: forall eff . 
  Config ->
  Eff (manager :: MANAGER | eff) ApiManager

foreign import _newApiManagerEmpty :: forall eff . Eff (manager :: MANAGER | eff) ApiManager

foreign import _on :: forall eff .
  Fn3 
    String 
    (Foreign -> Eff (MTProtoEffects eff) Unit) 
    ApiManager
    (Eff (MTProtoEffects eff) Unit)

foreign import _mtpInvokeApi :: forall a b c . 
  Fn4 
    String 
    a 
    b 
    ApiManager 
    (Promise c)

newApiManager :: forall eff. 
  Maybe Config -> 
  Eff (manager :: MANAGER | eff) ApiManager
newApiManager (Just config) = _newApiManager config
newApiManager Nothing = _newApiManagerEmpty

mtpInvokeApi :: forall a b c eff. 
  String -> 
  a -> 
  b -> 
  ApiManager -> 
  (Aff (MTProtoEffects eff) c)
mtpInvokeApi method params options manager = do
  toAff result
  where
    result = runFn4 _mtpInvokeApi method params options manager

on :: forall eff. 
  String -> 
  (Foreign -> Eff (MTProtoEffects eff) Unit) ->
  ApiManager ->
  (Eff (MTProtoEffects eff) Unit)
on event handler manager = do
  runFn3 _on event handler manager

