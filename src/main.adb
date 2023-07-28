with RP.Interpolator;
with RP.Device;
with Pico.Pimoroni.Display; use Pico.Pimoroni.Display;
with Pico.Pimoroni.Display.Buttons; use Pico.Pimoroni.Display.Buttons;
with Interfaces; use Interfaces;
with System;
with HAL; use HAL;
with Unchecked_Conversion;
with RP.Clock;
with System.Storage_Elements; use System.Storage_Elements;
with Interpolator_Simulator; use Interpolator_Simulator;
with Interpolator; use Interpolator;



procedure Main is
   Scale_min : constant := 0.0078125;
   Scale_max : constant := 1.0;
   Skew_min : constant := -0.5;
   Skew_max : constant := 0.5;
   Skew_step : constant := 0.015625;
   Xscale : Float;
   D_xscale : Float;
   Yscale : Float;
   D_yscale : Float;
   Skew : Float;
   D_skew : Float;
   
   --  Interp0 : Interpolator_Simulator.Interpolator;
   Interp0 : RP.Interpolator.INTERP_Peripheral renames RP.Device.INTERP_0;
   
   type Color_Array is array (UInt8 range 1 .. 4) of Bitmap_Color;
   Black : Bitmap_Color := (0, 0, 0);
   --  Grey : Bitmap_Color := (20, 40, 20);
   RP_Leaf : Bitmap_Color := (107,192,72);
   RP_Berry : Bitmap_Color := (196,25,73);
   Colors : Color_Array := (Black, RP_Leaf, RP_Berry, Blue);
   
   type Logo_array is array (UInt32 range <>) of UInt8;
   Demo_logo : Logo_array :=
     (4,4,4,1,1,1,1,4,1,1,1,1,4,4,4,4,
      4,4,1,2,2,2,1,1,1,2,2,2,1,4,4,4,
      4,4,1,2,2,1,2,1,2,1,2,2,1,4,4,4,
      4,4,4,1,2,2,1,1,1,2,2,1,4,4,4,4,
      4,4,4,4,1,1,1,3,1,1,1,4,4,4,4,4,
      4,4,4,1,3,1,3,3,3,1,3,1,4,4,4,4,
      4,4,1,3,1,1,1,1,1,1,1,3,1,4,4,4,
      4,1,1,3,1,3,3,1,3,3,1,3,1,1,4,4,
      4,1,3,1,3,3,3,1,3,3,3,1,3,1,4,4,
      4,1,3,1,1,1,1,3,1,1,1,1,3,1,4,4,
      4,1,1,1,3,1,3,3,3,1,3,1,1,1,4,4,
      4,4,1,3,3,1,3,3,3,1,3,3,1,4,4,4,
      4,4,1,1,3,1,1,1,1,1,3,1,1,4,4,4,
      4,4,4,1,1,1,3,3,3,1,1,1,4,4,4,4,
      4,4,4,4,4,1,1,1,1,1,4,4,4,4,4,4,
      4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4);

   
   function Int_To_UInt is new Unchecked_Conversion (Integer_32,UInt32);
   
   procedure Initialize is 
   begin
      Xscale := 0.125;
      D_xscale := 0.8;
      Yscale := 0.125;
      D_yscale := 0.8;
      Skew := 0.0;
      D_skew := Skew_step;
   end Initialize;
   
   procedure Texture_Fill_Line (Init_Index: Natural;
                                U : UInt32;
                                V : UInt32;
                                DU : UInt32;
                                DV : UInt32;
                                Count : Natural)
     with Pre => Init_Index < Nbr_Of_Pixels - Count + 1;
   
   procedure Texture_Fill_Line (Init_Index: Natural;
                                U : UInt32;
                                V : UInt32;
                                DU : UInt32;
                                DV : UInt32;
                                Count : Natural) is
      
   begin
      Set_Accum (Interp0, 0, U);
      Set_Base (Interp0, 0, DU);
      Set_Accum (Interp0, 1, V);
      Set_Base (Interp0, 1, DV);
           
      for I in Init_Index .. Init_Index + Count - 1 loop
         declare
            
           Color_Index : UInt32;
         begin 
            Pop (Interp0, 2, Color_Index);
            Set_Color (Colors ( Demo_Logo (Color_Index)));
            Pico.Pimoroni.Display.Set_Pixel (I);
         end;
      end loop;
   end Texture_Fill_Line;
   
   procedure Fill_Buffer (W : Natural;
                          H : Integer;
                          Xscale : Float;
                          Yscale : Float;
                          Skew : Float) is 
      DX : UInt32;
      DY : UInt32;
      S : Integer_32;
   begin
      Set_Ctrl_Lane(Interp0,
                                           Num_Lane => 0,
                                           SHIFT => 16,
                                           MASK_LSB => 0,
                                           MASK_MSB => 3,
                                           SIGNED => False,
                                           CROSS_INPUT => False,
                                           CROSS_RESULT => False,
                                           ADD_RAW => True);
      Set_Ctrl_Lane(Interp0,
                                           Num_Lane => 1,
                                           SHIFT => 12,
                                           MASK_LSB => 4,
                                           MASK_MSB => 7,
                                           SIGNED => False,
                                           CROSS_INPUT => False,
                                           CROSS_RESULT => False,
                                           ADD_RAW => True);
      Set_Base (Interp0, 2, UInt32 (0));
      DX := UInt32 (65536.0 * Xscale);
      DY := UInt32 (65536.0 * Yscale);
      S := Integer_32 (65536.0 * Skew);
      for L in Natural range 0 .. H - 1 loop
         Texture_Fill_Line (L * W, 0, UInt32(L) * DY, DX, Int_To_UInt (S), W);
      end loop;
   end Fill_Buffer;
   
   procedure Step_Skew is
   begin
      Skew := Skew + D_skew;
      if Skew < Skew_min then
         Skew := Skew_min;
         d_skew := Skew_step;
      elsif  Skew > Skew_max then
         Skew := Skew_max;
         D_skew := -Skew_step;
      end if;
   end Step_Skew;
   
   procedure Step_Xscale is
   begin
      Xscale := Xscale * D_xscale;
      if Xscale < Scale_min then
         Xscale := Scale_min;
         D_xscale := 1.25;
      elsif Xscale > Scale_max then
         Xscale := Scale_max;
         D_xscale := 0.8;
      end if;
   end Step_Xscale;

   procedure Step_Yscale is
      begin
      Yscale := Yscale * D_yscale;
      if Yscale < Scale_min then
         Yscale := Scale_min;
         D_yscale := 1.25;
      elsif Yscale > Scale_max then
         Yscale := Scale_max;
         D_yscale := 0.8;
      end if;
   end Step_Yscale;
   
   Cur_Bool : Boolean;
   
begin
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Device.Timer.Enable;
   Pico.Pimoroni.Display.Initialize;
   Initialize;
   loop
      Fill_Buffer (Pico.Pimoroni.Display.Screen_Width,
                   Pico.Pimoroni.Display.Screen_Height,
                   Xscale,
                   Yscale,
                   Skew);      
      
      Pico.Pimoroni.Display.Update (Clear => True);
      Pico.Pimoroni.Display.Buttons.Poll_Buttons;
      Pico.Pimoroni.Display.Buttons.Pressed(A, Cur_Bool);
      if Cur_Bool then
         Step_Xscale;
      end if;
      Pico.Pimoroni.Display.Buttons.Pressed(B, Cur_Bool);
      if Cur_Bool then
         Step_Yscale;
      end if;
      Pico.Pimoroni.Display.Buttons.Pressed(X, Cur_Bool);
      if Cur_Bool then
         Step_Skew;
      end if;
      if Pico.Pimoroni.Display.Buttons.Just_Pressed(Y) then
         Initialize;
      end if;
      
   end loop;
  
end Main;
