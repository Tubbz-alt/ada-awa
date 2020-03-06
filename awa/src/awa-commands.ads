-----------------------------------------------------------------------
--  awa-commands -- AWA commands for server or admin tool
--  Copyright (C) 2019, 2020 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------
with Ada.Finalization;
with Util.Commands;
with AWA.Applications;
with Ada.Exceptions;
private with Keystore.Passwords;
private with Keystore.Passwords.GPG;
private with Util.Commands.Consoles.Text;
private with ASF.Applications;
private with AWA.Applications.Factory;
private with Keystore.Properties;
private with Keystore.Files;
private with Keystore.Passwords.Keys;
private with GNAT.Command_Line;
private with GNAT.Strings;
package AWA.Commands is

   Error : exception;

   FILL_CONFIG        : constant String := "fill-mode";
   GPG_CRYPT_CONFIG   : constant String := "gpg-encrypt";
   GPG_DECRYPT_CONFIG : constant String := "gpg-decrypt";
   GPG_LIST_CONFIG    : constant String := "gpg-list-keys";

   subtype Argument_List is Util.Commands.Argument_List;

   type Context_Type is limited new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Initialize (Context : in out Context_Type);

   overriding
   procedure Finalize (Context : in out Context_Type);

   --  Returns True if a keystore is used by the configuration and must be unlocked.
   function Use_Keystore (Context : in Context_Type) return Boolean;

   --  Open the keystore file using the password password.
   procedure Open_Keystore (Context : in out Context_Type);

   --  Get the keystore file path.
   function Get_Keystore_Path (Context : in out Context_Type) return String;

   --  Configure the application by loading its configuration file and merging it with
   --  the keystore file if there is one.
   procedure Configure (Application : in out AWA.Applications.Application'Class;
                        Name        : in String;
                        Context     : in out Context_Type);

   procedure Print (Context : in out Context_Type;
                    Ex      : in Ada.Exceptions.Exception_Occurrence);

   --  Configure the logs.
   procedure Configure_Logs (Root    : in String;
                             Debug   : in Boolean;
                             Dump    : in Boolean;
                             Verbose : in Boolean);

private

   function "-" (Message : in String) return String is (Message);

   procedure Load_Configuration (Context : in out Context_Type;
                                 Path    : in String);

   package GC renames GNAT.Command_Line;

   type Field_Number is range 1 .. 256;

   type Notice_Type is (N_USAGE, N_INFO, N_ERROR);

   package Consoles is
     new Util.Commands.Consoles (Field_Type  => Field_Number,
                                 Notice_Type => Notice_Type);

   package Text_Consoles is
      new Consoles.Text;

   subtype Justify_Type is Consoles.Justify_Type;

   type Context_Type is limited new Ada.Finalization.Limited_Controlled with record
      Console           : Text_Consoles.Console_Type;
      Wallet            : aliased Keystore.Files.Wallet_File;
      Info              : Keystore.Wallet_Info;
      Config            : Keystore.Wallet_Config := Keystore.Secure_Config;
      Secure_Config     : Keystore.Properties.Manager;
      App_Config        : ASF.Applications.Config;
      File_Config       : ASF.Applications.Config;
      Factory           : AWA.Applications.Factory.Application_Factory;
      Provider          : Keystore.Passwords.Provider_Access;
      Key_Provider      : Keystore.Passwords.Keys.Key_Provider_Access;
      Slot              : Keystore.Key_Slot;
      Version           : aliased Boolean := False;
      Verbose           : aliased Boolean := False;
      Debug             : aliased Boolean := False;
      Dump              : aliased Boolean := False;
      Zero              : aliased Boolean := False;
      Config_File       : aliased GNAT.Strings.String_Access;
      Wallet_File       : aliased GNAT.Strings.String_Access;
      Data_Path         : aliased GNAT.Strings.String_Access;
      Wallet_Key_File   : aliased GNAT.Strings.String_Access;
      Password_File     : aliased GNAT.Strings.String_Access;
      Password_Env      : aliased GNAT.Strings.String_Access;
      Unsafe_Password   : aliased GNAT.Strings.String_Access;
      Password_Socket   : aliased GNAT.Strings.String_Access;
      Password_Command  : aliased GNAT.Strings.String_Access;
      Password_Askpass  : aliased Boolean := False;
      No_Password_Opt   : Boolean := False;
      Command_Config    : GC.Command_Line_Configuration;
      First_Arg         : Positive := 1;
      GPG               : Keystore.Passwords.GPG.Context_Type;
   end record;

   procedure Setup_Password_Provider (Context : in out Context_Type);

   procedure Setup_Key_Provider (Context : in out Context_Type);

   --  Setup the command before parsing the arguments and executing it.
   procedure Setup_Command (Config  : in out GC.Command_Line_Configuration;
                            Context : in out Context_Type);

   function Sys_Daemon (No_Chdir : in Integer; No_Close : in Integer) return Integer
     with Import => True, Convention => C, Link_Name => "daemon";
   pragma Weak_External (Sys_Daemon);

end AWA.Commands;
