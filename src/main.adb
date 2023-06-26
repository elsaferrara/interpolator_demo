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
    Bool : Boolean := False; 
   
   Interp0 : RP.Interpolator.INTERP_Peripheral renames RP.Device.INTERP_0;
   
   type Color_Array is array (UInt8 range 1 .. 4) of Bitmap_Color;
   Black : Bitmap_Color := (0, 0, 0);
   Grey : Bitmap_Color := (20, 40, 20);
   RP_Leaf : Bitmap_Color := (107,192,72);
   RP_Berry : Bitmap_Color := (196,25,73);
   Colors : Color_Array := (Black, RP_Leaf, RP_Berry, Blue);
   
   type Logo_array is array (Natural range <>) of UInt8;
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
      Bool:= False;
   end Initialize;
   
   procedure Texture_Mapping_Setup (Texture : Logo_array; 
                                    UV_Fractional_Bits : HAL.UInt5;
                                    Texture_Width_Bits : HAL.UInt5;
                                   Texture_Height_Bits : HAL.UInt5)
   is
   begin
      Interp0.CTRL := (others => <>);
      Interp0.CTRL (0) := (ADD_RAW => True,
                           SHIFT => UV_Fractional_Bits,
                           MASK_LSB => 0,
                           MASK_MSB => Texture_Width_Bits - 1,
                           others => <>);
      
      Interp0.CTRL (1) := (ADD_RAW => True,
                           SHIFT => UV_Fractional_Bits - Texture_Width_Bits,
                           MASK_LSB => Texture_Width_Bits,
                           MASK_MSB => Texture_Width_Bits + Texture_Height_Bits - 1,
                           others => <>);
      
      Interp0.BASE (2) := UInt32 (To_Integer (Texture'Address));

   end Texture_Mapping_Setup;
   
   procedure Texture_Fill_Line (Init_Index: Integer;
                                U : UInt32;
                                V : UInt32;
                                DU : UInt32;
                                DV : UInt32;
                                Count : Integer) is
      
   begin
      Interp0.ACCUM (0) := U;
      Interp0.BASE (0) := DU;
      Interp0.ACCUM (1) := V;
      Interp0.BASE (1) := DV;
           
      for I in Init_Index .. Init_Index + Count - 1 loop
         declare
           Color_Index : UInt8 with Address => To_Address ( Integer_Address (Interp0.POP (2)));
         begin 
            
            Set_Color (Colors ( Color_Index));
            Pico.Pimoroni.Display.Set_Pixel (I);
            
         end;
      end loop;
   end Texture_Fill_Line;
   
   procedure Fill_Buffer (W : Integer;
                          H : Integer;
                          Xscale : Float;
                          Yscale : Float;
                          Skew : Float) is 
      DX : UInt32;
      DY : UInt32;
      S : Integer_32;
   begin

      Texture_Mapping_Setup (Demo_logo, 16, 4, 4);
      DX := UInt32 (65536.0 * Xscale);
      DY := UInt32 (65536.0 * Yscale);
      S := Integer_32 (65536.0 * Skew);
      for L in 0 .. H - 1 loop
         Texture_Fill_Line (L * Screen_Width, 0, UInt32(L) * DY, DX, Int_To_UInt (S), W);
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
      if Bool then
      Set_Color (Red);
      Pico.Pimoroni.Display.Fill_Rect (((10, 10), 100, 100));
      end if;
      
      Pico.Pimoroni.Display.Update (Clear => True);
      Pico.Pimoroni.Display.Buttons.Poll_Buttons;
      if Pico.Pimoroni.Display.Buttons.Pressed(A) then
         Step_Xscale;
      end if;
      if Pico.Pimoroni.Display.Buttons.Pressed(B) then
         Step_Yscale;
      end if;
      if Pico.Pimoroni.Display.Buttons.Pressed(X) then
         Step_Skew;
      end if;
      if Pico.Pimoroni.Display.Buttons.Just_Pressed(Y) then
         Initialize;
      end if;
      
   end loop;
  
end Main;
