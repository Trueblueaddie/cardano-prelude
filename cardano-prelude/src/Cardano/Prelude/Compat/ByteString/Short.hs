{-# LANGUAGE CPP #-}
{-# LANGUAGE MagicHash #-}

module Cardano.Prelude.Compat.ByteString.Short
  ( unsafeShortByteStringIndex
  ) where

-- GHC >= 9.0 does not export unsafeIndex for ShortByteString
-- GHC < 9.0 does not export the ShortByteString constructor SBS.
-- Coniditional compile to work around this.

#if __GLASGW_HASKELL__ >= 900
import Data.ByteString.Short (ShortByteString(..))
import Data.Int (Int)
import Data.Word (Word8)
import GHC.Exts (indexWord8Array#)

unsafeShortByteStringIndex :: ShortByteString -> Int -> Word8
unsafeShortByteStringIndex (SBS ba#) (I# i#) = W8# (indexWord8Array# ba# i#)

#else

import Data.ByteString.Short (ShortByteString, index)
import Data.Int (Int)
import Data.Word (Word8)

unsafeShortByteStringIndex :: ShortByteString -> Int -> Word8
unsafeShortByteStringIndex = index

#endif
