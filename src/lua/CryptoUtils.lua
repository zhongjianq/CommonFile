--
-- Author: thisgf
-- Date: 2015-08-11 17:41:35
-- 加解密相关工具 static class

CryptoUtils = class("CryptoUtils")

function CryptoUtils:md5String(str)
    str = tostring(str)
    return Crypto:MD5String(str, #str)
end