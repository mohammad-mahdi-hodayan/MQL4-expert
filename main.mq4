/*------------------------------------------------------------------------------------------------------------------
// this project is just a test to start mql codeing by a new programmer...

███╗░░░███╗░█████╗░██╗░░██╗░█████╗░███╗░░░███╗███╗░░░███╗░█████╗░██████╗░  ███╗░░░███╗░█████╗░██╗░░██╗██████╗░██╗
████╗░████║██╔══██╗██║░░██║██╔══██╗████╗░████║████╗░████║██╔══██╗██╔══██╗  ████╗░████║██╔══██╗██║░░██║██╔══██╗██║
██╔████╔██║██║░░██║███████║███████║██╔████╔██║██╔████╔██║███████║██║░░██║  ██╔████╔██║███████║███████║██║░░██║██║
██║╚██╔╝██║██║░░██║██╔══██║██╔══██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██║░░██║  ██║╚██╔╝██║██╔══██║██╔══██║██║░░██║██║
██║░╚═╝░██║╚█████╔╝██║░░██║██║░░██║██║░╚═╝░██║██║░╚═╝░██║██║░░██║██████╔╝  ██║░╚═╝░██║██║░░██║██║░░██║██████╔╝██║
╚═╝░░░░░╚═╝░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░░░╚═╝╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═════╝░  ╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝

------------------------------------------------------------------------------------------------------------------*/


// set defult values
double beforeprice = 0;
double issellok = 1;
double isbuyok = 1;
double istradeon = 1;
// save orders data per SB line in array
string savedordersdata[];




//+------------------------------------------------------------------+
//|         main code, that will runs as a loop every frame          |
//+------------------------------------------------------------------+
int start()
  {
// import indicator file from users system
   double indicatorimporter = iCustom(NULL,0,"SD.TRex Th3 (5)",13,1,0);
// get lines info (float result will return by these lines, ex : 1.08565)
   double Hline_sell_and_buy = ObjectGetDouble(0,"mmd",OBJPROP_PRICE1);
   double st = ObjectGetDouble(0,"sl_sell",OBJPROP_PRICE1);
   double st_b = ObjectGetDouble(0,"sl_buy",OBJPROP_PRICE1);
// calculator difrence between line and sl line to use for stopline in orders.
   double difrence_between_Hline_and_slline = st - Hline_sell_and_buy;
   double difrence_between_Hline_and_slline_buy = Hline_sell_and_buy - st_b ;
   //Print("stoploss sell : "+difrence_between_Hline_and_slline);

// get indicator value and filter to use as array value, this part will be tps in orders
   string indicatordata = ObjectDescription("TR_ATR TPLine1");
   int filter_ind_text1 = StringReplace(indicatordata,"#SL:--","");
   int filter_ind_text2 = StringReplace(indicatordata,"#TP1+","");
   int filter_ind_text3 = StringReplace(indicatordata,"#TP2+","");
   int filter_ind_text4 = StringReplace(indicatordata,"#TP3+","");
   int filter_ind_text5 = StringReplace(indicatordata,"    ",",");
   string  to_split=indicatordata;
   string sep=",";
   ushort u_sep;
   string indicatordata_array[];
   u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(to_split,u_sep,indicatordata_array);
   int ind_SL=StrToInteger(indicatordata_array[1]);
   int ind_TP1=StrToInteger(indicatordata_array[1]);
   int ind_TP2=StrToInteger(indicatordata_array[2]);
   int ind_TP3=StrToInteger(indicatordata_array[3]);

// get current price of market as ASK & BID
   double PriceAsk = MarketInfo(Symbol(), MODE_ASK);
   double PriceBid = MarketInfo(Symbol(), MODE_BID);



int obj_total=ObjectsTotal();
 
     // SB Line detected
// Hline is empty... waiting to draw a line by user
   if(Hline_sell_and_buy == 0)     {     }
// Hline has been set. it's time to action !
   else
     {
        Print("mew");
      // chart from down to line (we should SELL):
      if((beforeprice < Hline_sell_and_buy) && (Hline_sell_and_buy < PriceBid))
        {
         if(istradeon == 1)
           {
            //Print("we have 5 sell orders !");
            int OR1 = OrderSend(Symbol(),OP_SELL,0.1,Ask,3,Bid+difrence_between_Hline_and_slline,Bid-((ind_TP1*Point)*10));
            int OR2 = OrderSend(Symbol(),OP_SELL,0.1,Ask,3,Bid+difrence_between_Hline_and_slline,Bid-((ind_TP2*Point)*10));
            int OR3 = OrderSend(Symbol(),OP_SELL,0.1,Ask,3,Bid+difrence_between_Hline_and_slline,Bid-((ind_TP3*Point)*10));
            int OR4 = OrderSend(Symbol(),OP_SELL,0.1,Ask,3,Bid+difrence_between_Hline_and_slline,0);
            int OR5 = OrderSend(Symbol(),OP_SELL,0.1,Ask,3,Bid+difrence_between_Hline_and_slline,0);
            istradeon = 0;
           }

         // update price for next start loop
         beforeprice = PriceBid;

         if(OrdersTotal()<1)
           {
            istradeon = 1;
           }

         // ============================================ Brreake even code ==============================================
         // print open orders
         /*
            for(int m=OrdersTotal(); m>=0; m--)
           {
            //select an order
            if(OrderSelect(m,SELECT_BY_POS,MODE_TRADES))
              {
               OrderPrint();
               Print("inf order : ");
              }

           }*/
         //---
         for(int i_for=OrdersTotal(); i_for>=0; i_for--)
           {

            //select an order
            if(OrderSelect(i_for,SELECT_BY_POS,MODE_TRADES))
              {
               int pips= ind_TP1*10;
               //make sure its the right currency pair
               if(OrderSymbol()==_Symbol)
                 {
                  //check if buy or sell


                  if(OrderType()==OP_SELL)
                    {
                     if(Bid<=(OrderOpenPrice()-pips*_Point))
                       {
                        bool evensell=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);
                        if(!evensell)
                          {
                           Print("Failed to set Break Even Point for order #",OrderTicket());
                          }
                        else
                          {
                           Print("Break Even point has been set for order #",OrderTicket());
                          }
                       }
                    }

                 }
              }
           }
         // ============================================ Brreake even code ==============================================

         // ============================================ trailing code =============================================
         //---
         for(int t=OrdersTotal(); t>=0; t--)
           {
            int pipstrailing=ind_SL*10;
            //select an order
            if(OrderSelect(t,SELECT_BY_POS,MODE_TRADES))
              {
               //make sure its the right currency pair
               if(OrderSymbol()==_Symbol)
                 {
                  //check if buy or sell


                  if(OrderType()==OP_SELL)
                    {
                     if((Bid<(OrderOpenPrice()-pipstrailing*_Point))&&(OrderStopLoss()>Bid+pipstrailing*_Point)&&(Bid<=OrderOpenPrice()))
                       {
                        bool evenselltr=OrderModify(OrderTicket(),OrderOpenPrice(),Bid+pipstrailing*_Point,OrderTakeProfit(),0);
                        if(!evenselltr)
                          {
                           Print("Failed to set Trailing Stop Point for order #",OrderTicket());
                          }
                        else
                          {
                           Print("Trailing Stop point has been set for order #",OrderTicket());
                          }
                       }
                    }

                 }
              }
           }
        }


      // chart from up to line (we should BUY):
      if((beforeprice > Hline_sell_and_buy) && (Hline_sell_and_buy > PriceBid))
        {
         if(istradeon == 1)
           {
            //Print("we have 5 BUY orders !");
            int OR1_B = OrderSend(Symbol(),OP_BUY,0.1,Ask,3,Bid-difrence_between_Hline_and_slline_buy,Bid+((ind_TP1*Point)*10));
            int OR2_B = OrderSend(Symbol(),OP_BUY,0.1,Ask,3,Bid-difrence_between_Hline_and_slline_buy,Bid+((ind_TP2*Point)*10));
            int OR3_B = OrderSend(Symbol(),OP_BUY,0.1,Ask,3,Bid-difrence_between_Hline_and_slline_buy,Bid+((ind_TP3*Point)*10));
            int OR4_B = OrderSend(Symbol(),OP_BUY,0.1,Ask,3,Bid-difrence_between_Hline_and_slline_buy,0);
            int OR5_B = OrderSend(Symbol(),OP_BUY,0.1,Ask,3,Bid-difrence_between_Hline_and_slline_buy,0);
            istradeon = 0;
           }

         // update price for next start loop
         beforeprice = PriceBid;

         if(OrdersTotal()<1)
           {
            istradeon = 1;
           }

         // Breake even =---=============================================================================--=
         // print open orders

         //---
         for(int i_buy=OrdersTotal(); i_buy>=0; i_buy--)
           {

            //select an order
            if(OrderSelect(i_buy,SELECT_BY_POS,MODE_TRADES))
              {
               int pips_buy= ind_TP1*10;
               //make sure its the right currency pair
               if(OrderSymbol()==_Symbol)
                 {
                  //check if buy or sell


                  if(OrderType()==OP_BUY)
                    {
                     if(Ask>=(OrderOpenPrice()+pips_buy*_Point))
                       {
                        bool evenbuy=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);
                        if(!evenbuy)
                          {
                           Print("Failed to set Break Even Point for order #",OrderTicket());
                          }
                        else
                          {
                           Print("Break Even point has been set for order #",OrderTicket());
                          }
                       }
                    }

                 }
              }
           }
         // end of Breake even =---=============================================================================--==


         // ============================================ trailing code =============================================
         //---
         for(int t_buy=OrdersTotal(); t_buy>=0; t_buy--)
           {
            int pipstrailing_buy=ind_SL*10;
            //select an order
            if(OrderSelect(t_buy,SELECT_BY_POS,MODE_TRADES))
              {
               //make sure its the right currency pair
               if(OrderSymbol()==_Symbol)
                 {
                  //check if buy or sell


                  if(OrderType()==OP_BUY)
                    {
                     if((Ask>(OrderOpenPrice()+pipstrailing_buy*_Point))&&(OrderStopLoss()<Ask-pipstrailing_buy*_Point)&&(Ask>=OrderOpenPrice()))
                       {
                        bool evenbuytr=OrderModify(OrderTicket(),OrderOpenPrice(),Ask-pipstrailing_buy*_Point,OrderTakeProfit(),0);
                        if(!evenbuytr)
                          {
                           Print("Failed to set Trailing Stop Point for order #",OrderTicket());
                          }
                        else
                          {
                           Print("Trailing Stop point has been set for order #",OrderTicket());
                          }
                       }
                    }

                 }
              }
           }
        }
     }

        // ============================================ end trailing ==============================================

   return 0;

    }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
