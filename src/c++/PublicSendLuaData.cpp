//  PublicSendLuaData.cpp
//
//  Lua and C++/c 交互类

#include "PublicSendLuaData.h"
#include "CCLuaEngine.h"

PublicSendLuaData* PublicSendLuaData::m_instance = NULL;
PublicSendLuaData* PublicSendLuaData::getInstance(){
    if(!m_instance)
    {
        
        m_instance = new PublicSendLuaData();
    }
    return m_instance;
}
//获取变量名值
const char* PublicSendLuaData::getLuaVarString(const char* luaFileName,const char* varName){
    
    lua_State*  ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
    
    int isOpen = luaL_dofile(ls, getFileFullPath(luaFileName));
    if(isOpen!=0){
        CCLOG("Open Lua Error: %i", isOpen);
        return NULL;
    }
    
    lua_settop(ls, 0);
    lua_getglobal(ls, varName);
    
    int statesCode = lua_isstring(ls, 1);
    if(statesCode!=1){
        CCLOG("Open Lua Error: %i", statesCode);
        return NULL;
    }
    
    const char* str = lua_tostring(ls, 1);
    lua_pop(ls, 1);
    
    return str;
}

const char* PublicSendLuaData::getLuaVarOneOfTable(const char* luaFileName,const char* varName,const char* keyName){
    
    lua_State*  ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
    
    int isOpen = luaL_dofile(ls, getFileFullPath(luaFileName));
    if(isOpen!=0){
        CCLOG("Open Lua Error: %i", isOpen);
        return NULL;
    }
    
    lua_getglobal(ls, varName);
    
    int statesCode = lua_istable(ls, -1);
    if(statesCode!=1){
        CCLOG("Open Lua Error: %i", statesCode);
        return NULL;
    }
    
    lua_pushstring(ls, keyName);
    lua_gettable(ls, -2);
    const char* valueString = lua_tostring(ls, -1);
    
    lua_pop(ls, -1);
    
    return valueString;
}
//执行Lua表，返回表结构
const char* PublicSendLuaData::getLuaVarTable(const char* luaFileName,const char* varName){
    lua_State*  ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
    
    int isOpen = luaL_dofile(ls, getFileFullPath(luaFileName));
    if(isOpen!=0){
        CCLOG("Open Lua Error: %i", isOpen);
        return NULL;
    }
    
    lua_getglobal(ls, varName);
    
    int it = lua_gettop(ls);
    lua_pushnil(ls);
    
    string result="";
    
    while(lua_next(ls, it))
    {
        string key = lua_tostring(ls, -2);
        string value = lua_tostring(ls, -1);
        
        result=result+key+":"+value+"\t";
        
        lua_pop(ls, 1);
    }
    lua_pop(ls, 1);
    
    return result.c_str();
}

//带参执行Lua方法有返回值
const char* PublicSendLuaData::callLuaFuncParReturn(const char* luaFileName,const char* functionName,CCArray* arraypar,CCArray* arraypartype){
    lua_State*  ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
    
    int isOpen = luaL_dofile(ls, getFileFullPath(luaFileName));
    if(isOpen!=0){
        CCLOG("Open Lua Error: %i", isOpen);
        return NULL;
    }
    
    lua_getglobal(ls, functionName);
    int countnum = arraypar->count();
    if(countnum>0)
    {
        for (int i = 0; i<arraypar->count(); i++) {
            CCString* typestr = (CCString*)arraypartype->objectAtIndex(i);
            CCString* strnr = (CCString*)arraypar->objectAtIndex(i);
            if(typestr->isEqual(CCString::create("string")))
            {
                lua_pushstring(ls, strnr->getCString());
            }
            else if(typestr->isEqual(CCString::create("int")))
            {
                lua_pushnumber(ls, strnr->intValue());
            }
            else if(typestr->isEqual(CCString::create("bool")))
            {
                lua_pushboolean(ls, strnr->boolValue());
            }
        }
    }
    /*
     lua_call
     第一个参数:函数的参数个数
     第二个参数:函数返回值个数
     */
    lua_call(ls, countnum, 1);
    
    const char* iResult = lua_tostring(ls, -1);
    
    return iResult;
}

//带参执行Lua方法无返回值
const void PublicSendLuaData::callLuaFuncPar(const char* luaFileName,const char* functionName,CCArray* arraypar,CCArray* arraypartype){
    lua_State*  ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
    
    int isOpen = luaL_dofile(ls, getFileFullPath(luaFileName));
    if(isOpen!=0){
        CCLOG("Open Lua Error: %i", isOpen);
    }
    
    lua_getglobal(ls, functionName);
    int countnum = arraypar->count();
    if(countnum>0)
    {
        for (int i = 0; i<arraypar->count(); i++) {
            CCString* typestr = (CCString*)arraypartype->objectAtIndex(i);
            CCString* strnr = (CCString*)arraypar->objectAtIndex(i);
            if(typestr->isEqual(CCString::create("string")))
            {
                lua_pushstring(ls, strnr->getCString());
            }
            else if(typestr->isEqual(CCString::create("int")))
            {
                lua_pushnumber(ls, strnr->intValue());
            }
            else if(typestr->isEqual(CCString::create("bool")))
            {
                lua_pushboolean(ls, strnr->boolValue());
            }
        }
    }
    /*
     lua_call
     第一个参数:函数的参数个数
     第二个参数:函数返回值个数
     */
    lua_call(ls, countnum, 0);
 
}


const char* PublicSendLuaData::getFileFullPath(const char* fileName){
    return CCFileUtils::sharedFileUtils()->fullPathForFilename(fileName).c_str();
}

PublicSendLuaData::~PublicSendLuaData(){
    
    CC_SAFE_DELETE(m_instance);
    m_instance=NULL;
}