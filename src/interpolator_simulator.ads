with HAL; use HAL;
package Interpolator_Simulator with SPARK_Mode is

   
   --  private
   type Lane_Config is record
      SHIFT          : UInt5   := 0;
      MASK_LSB       : UInt5   := 0;
      MASK_MSB       : UInt5   := 31;
      SIGNED         : Boolean := False;
      CROSS_INPUT    : Boolean := False;
      CROSS_RESULT   : Boolean := False;
      ADD_RAW        : Boolean := False;
      --  FORCE_MSB      : UInt2   := 0;
      --  BLEND          : Boolean := False;
      --  CLAMP          : Boolean := False;
      --  OVERF           : Boolean := False;
      --  OVERF1          : Boolean := False;
      --  OVERF0          : Boolean := False;
   end record;
   
   type Lane is range 0 .. 2;
   
   type ACCUM_Register  is array (Lane range 0 .. 1) of UInt32;
   type LANE_Register   is array (Lane) of UInt32;
   type CTRL_Register   is array (Lane range 0 .. 1) of Lane_Config;
   --  type ADD_Register    is array (Lane range 0 .. 1) of UInt24;
   
   type Interpolator is record
      ACCUM       : ACCUM_Register := (others => 0);
      BASE        : LANE_Register := (others => 0);
      POP         : LANE_Register;
      PEEK        : LANE_Register;
      CTRL        : CTRL_Register;
   end record;  
   
   procedure Lane_0_Config (Interp : in out Interpolator;
                            SHIFT          : UInt5;
                            MASK_LSB       : UInt5;
                            MASK_MSB       : UInt5;
                            SIGNED         : Boolean;
                            CROSS_INPUT    : Boolean;
                            CROSS_RESULT   : Boolean;
                            ADD_RAW        : Boolean);
   procedure Lane_1_Config (Interp : in out Interpolator;
                            SHIFT          : UInt5;
                            MASK_LSB       : UInt5;
                            MASK_MSB       : UInt5;
                            SIGNED         : Boolean;
                            CROSS_INPUT    : Boolean;
                            CROSS_RESULT   : Boolean;
                            ADD_RAW        : Boolean);
      
   procedure Set_Base_0 (Interp : in out Interpolator;
                         Value : HAL.UInt32);
   procedure Set_Base_1 (Interp : in out Interpolator;
                         Value : HAL.UInt32);
   procedure Set_Base_2 (Interp : in out Interpolator;
                         Value : HAL.UInt32);
   
   procedure Set_Accum_0 (Interp : in out Interpolator;
                          Value : HAL.UInt32);
   procedure Set_Accum_1 (Interp : in out Interpolator;
                          Value : HAL.UInt32);
   
   procedure Update (Interp : in out Interpolator);
   procedure Next_State (Interp : in out Interpolator);
   
   function Peek_0 (Interp : Interpolator) return UInt32;
   function Peek_1 (Interp : Interpolator) return UInt32;
   function Peek_2 (Interp : Interpolator) return UInt32;

   procedure Pop_0 (Interp : in out Interpolator; Result : out UInt32);
   procedure Pop_1 (Interp : in out Interpolator; Result : out UInt32);
   procedure Pop_2 (Interp : in out Interpolator; Result : out UInt32);
   
end Interpolator_Simulator;
