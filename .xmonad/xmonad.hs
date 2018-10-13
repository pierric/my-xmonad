import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run(spawnPipe)
import XMonad.Actions.SpawnOn(spawnHere)
--import XMonad.Actions.Volume
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Hooks.Script(execScriptHook)
import qualified Graphics.X11.ExtraTypes.XF86 as XF86
import System.IO
import Control.Monad
import qualified XMonad.DBus as D

main = do
    -- xmproc <- spawnPipe "/home/jiasen/.cabal/bin/xmobar"
    dbus <- D.connect
    D.requestAccess dbus
    spawn "ibus-daemon"
    spawn "polybar laptop"
    xmonad $ desktopConfig
      { terminal = "/usr/bin/gnome-terminal"
      , borderWidth = 3
      , modMask = mod4Mask
      --, logHook = dynamicLogWithPP xmobarPP 
      --              { ppOutput = hPutStrLn xmproc
      --              , ppTitle = xmobarColor "green" "" . shorten 100
      --              , ppSep = "    "
      --              }
      , logHook = dynamicLogWithPP (myLogHook dbus) 
      , startupHook = myStartupHook
      } `additionalKeys` 
      [ ((0, xK_Print), spawn "deepin-screenshot")
      , ((mod4Mask, xK_n), spawn "nautilus")
      -- set/update the desktop background
      , ((mod4Mask, xK_b), spawn "feh --bg-scale $HOME/.xmonad/background.jpg")
      -- lock screen. 
      -- type the password in the blank screen to login again.
      , ((mod4Mask .|. controlMask, xK_l), spawn "slock")
      -- volume adjustment (doesn't work)
      --, ((0, XF86.xF86XK_AudioLowerVolume), void $ lowerVolume 4)
      --, ((0, XF86.xF86XK_AudioRaiseVolume), void $ raiseVolume 4)
      ]

-- For some reason, the xmonad starts up assuming an external monitor,
-- and leaves the internal one (eDP-1-1, if nvidia enabled) off.
-- I call xrandr to enable it.
myStartupHook = spawn "xrandr --output eDP-1-1 --auto" 

myLogHook dbus = def { ppOutput = D.send dbus }

