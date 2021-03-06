#define EXPERT_MAGIC 123456   // EA交易的幻数
//+------------------------------------------------------------------+
//| 关闭全部持仓                                                       |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 声明并初始化交易请求和交易请求结果
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal(); // 持仓数   
//--- 重做所有持仓
   for(int i=total-1; i>=0; i--)
     {
      //--- 订单的参数
      ulong  position_ticket=PositionGetTicket(i);                                      // 持仓价格
      string position_symbol=PositionGetString(POSITION_SYMBOL);                        // 交易品种 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);              // 小数位数
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // 持仓的幻数
      double volume=PositionGetDouble(POSITION_VOLUME);                                 // 持仓交易量
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // 持仓类型
      //--- 输出持仓信息
      PrintFormat("#%I64u %s  %s  %.2f  %s [%I64d]",
                  position_ticket,
                  position_symbol,
                  EnumToString(type),
                  volume,
                  DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                  magic);
      //--- 如果幻数匹配
    //  if(magic==EXPERT_MAGIC)
     //   {
         //--- 归零请求和结果值
         ZeroMemory(request);
         ZeroMemory(result);
         //--- 设置操作参数
         request.action   =TRADE_ACTION_DEAL;        // 交易操作类型
         request.position =position_ticket;          // 持仓价格
         request.symbol   =position_symbol;          // 交易品种 
         request.volume   =volume;                   // 持仓交易量
         request.deviation=5;                        // 允许价格偏差
         request.magic    =EXPERT_MAGIC;             // 持仓幻数
         //--- 根据持仓类型设置价格和订单类型 
         if(type==POSITION_TYPE_BUY)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type =ORDER_TYPE_SELL;
           }
         else
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
           }
         //--- 输出关闭信息
         PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
         //--- 发送请求
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // 如果不能发送请求，输出错误代码
         //--- 操作信息   
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
         //---
        }
   //  }
  }
