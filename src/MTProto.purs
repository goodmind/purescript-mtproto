module MTProto where
  
import Prelude
import Control.Promise (Promise, toAff)
import Data.Maybe (Maybe(..))
import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Data.Foreign (Foreign)
import Data.Foreign.Options (Options, toOptions)
import Data.Function.Uncurried (Fn4, Fn2, Fn3, runFn2, runFn3, runFn4)

type MTProtoEffects e = (mtproto :: MTPROTO | e)

foreign import data Schema :: *
foreign import data MtSchema :: *
foreign import data ApiManager :: *

instance showApiManager :: Show ApiManager where
  show _ = "ApiManager"

foreign import data MANAGER :: !
foreign import data MTPROTO :: !

data AsyncStorage = NewAsyncStorage 
  { get :: forall a. Array String -> (Promise a),
    set :: forall a b. a -> (Promise b),
    remove :: forall a. Array String -> (Promise a),
    clear :: forall a. Promise a
  }

type ServerConfig =
  { dev      :: Maybe Boolean,
    webogram :: Maybe Boolean
  }

type AppConfig =
  { debug   :: Maybe Boolean,
    storage :: Maybe AsyncStorage
  }

type ApiConfig =
  { invokeWithLayer :: Maybe Number,
    layer           :: Maybe Number,
    initConnection  :: Maybe Number,
    api_id          :: Maybe String,
    device_model    :: Maybe String,
    system_version  :: Maybe String,
    app_version     :: Maybe String,
    lang_code       :: Maybe String
  }

type Config = 
  { server :: Maybe ServerConfig,
    api :: Maybe ApiConfig,
    app :: Maybe AppConfig,
    schema :: Maybe Schema,
    mtSchema :: Maybe MtSchema
  }

foreign import _newApiManager :: forall eff.
  Fn2
    Config
    (forall a. {|a} -> Options {|a})
    (Eff (manager :: MANAGER | eff) ApiManager)

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
newApiManager (Just config) = runFn2 _newApiManager config toOptions
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

