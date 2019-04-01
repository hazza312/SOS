pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__kernel.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__kernel.adb");
pragma Suppress (Overflow_Check);

package body ada_main is

   E4 : Short_Integer; pragma Import (Ada, E4, "console_E");


   procedure adainit is
   begin
      null;

      E4 := E4 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_kernel");

   procedure main is
      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      adainit;
      Ada_Main_Program;
   end;

--  BEGIN Object file/option list
   --   /home/harry/Desktop/SOS/obj/console.o
   --   /home/harry/Desktop/SOS/obj/kernel.o
   --   -L/home/harry/Desktop/SOS/obj/
   --   -L/home/harry/Desktop/SOS/obj/
   --   -L/home/harry/opt/GNAT/2018/lib/gcc/x86_64-pc-linux-gnu/7.3.1/rts-zfp/adalib/
--  END Object file/option list   

end ada_main;
