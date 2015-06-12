-----------------------------------------------------------------------
--  awa-wikis-modules -- Module wikis
--  Copyright (C) 2015 Stephane Carrez
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
with AWA.Services.Contexts;
with AWA.Workspaces.Models;
with AWA.Workspaces.Modules;
with AWA.Modules.Get;
with AWA.Permissions;
with AWA.Permissions.Services;
with AWA.Wikis.Beans;
with AWA.Modules.Beans;

with ADO.Sessions;

with Util.Log.Loggers;
package body AWA.Wikis.Modules is

   Log : constant Util.Log.Loggers.Logger := Util.Log.Loggers.Create ("Awa.Wikis.Module");

   package Register is new AWA.Modules.Beans (Module => Wiki_Module,
                                              Module_Access => Wiki_Module_Access);

   --  ------------------------------
   --  Initialize the wikis module.
   --  ------------------------------
   overriding
   procedure Initialize (Plugin : in out Wiki_Module;
                         App    : in AWA.Modules.Application_Access;
                         Props  : in ASF.Applications.Config) is
   begin
      Log.Info ("Initializing the wikis module");

      --  Register here any bean class, servlet, filter.
      Register.Register (Plugin => Plugin,
                         Name   => "AWA.Wikis.Beans.Wiki_Space_Bean",
                         Handler => AWA.Wikis.Beans.Create_Wiki_Space_Bean'Access);

      AWA.Modules.Module (Plugin).Initialize (App, Props);

      --  Add here the creation of manager instances.
   end Initialize;

   --  ------------------------------
   --  Get the wikis module.
   --  ------------------------------
   function Get_Wiki_Module return Wiki_Module_Access is
      function Get is new AWA.Modules.Get (Wiki_Module, Wiki_Module_Access, NAME);
   begin
      return Get;
   end Get_Wiki_Module;

   --  ------------------------------
   --  Create the wiki space.
   --  ------------------------------
   procedure Create_Wiki_Space (Module : in Wiki_Module;
                                Wiki   : in out AWA.Wikis.Models.Wiki_Space_Ref'Class) is
      pragma Unreferenced (Module);

      Ctx   : constant Services.Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      User  : constant ADO.Identifier := Ctx.Get_User_Identifier;
      DB    : ADO.Sessions.Master_Session := AWA.Services.Contexts.Get_Master_Session (Ctx);
      WS    : AWA.Workspaces.Models.Workspace_Ref;
   begin
      Log.Info ("Creating new wiki space {0}", String '(Wiki.Get_Name));

      Ctx.Start;
      AWA.Workspaces.Modules.Get_Workspace (DB, Ctx, WS);

      --  Check that the user has the create permission on the given workspace.
      AWA.Permissions.Check (Permission => ACL_Create_Wiki_Space.Permission,
                             Entity     => WS);
      Wiki.Set_Workspace (WS);
      Wiki.Save (DB);

      --  Add the permission for the user to use the new wiki space.
      AWA.Permissions.Services.Add_Permission (Session => DB,
                                               User    => User,
                                               Entity  => Wiki);
      Ctx.Commit;

      Log.Info ("Wiki {0} created for user {1}",
                ADO.Identifier'Image (Wiki.Get_Id), ADO.Identifier'Image (User));
   end Create_Wiki_Space;

   --  ------------------------------
   --  Save the wiki space.
   --  ------------------------------
   procedure Save_Wiki_Space (Module : in Wiki_Module;
                              Wiki   : in out AWA.Wikis.Models.Wiki_Space_Ref'Class) is
      Ctx   : constant Services.Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      DB    : ADO.Sessions.Master_Session := AWA.Services.Contexts.Get_Master_Session (Ctx);
   begin
      Log.Info ("Updating wiki space {0}", String '(Wiki.Get_Name));

      Ctx.Start;

      --  Check that the user has the update permission on the given wiki space.
      AWA.Permissions.Check (Permission => ACL_Update_Wiki_Space.Permission,
                             Entity     => Wiki);
      Wiki.Save (DB);
      Ctx.Commit;
   end Save_Wiki_Space;

   --  ------------------------------
   --  Load the wiki space.
   --  ------------------------------
   procedure Load_Wiki_Space (Module : in Wiki_Module;
                              Wiki   : in out AWA.Wikis.Models.Wiki_Space_Ref'Class;
                              Id     : in ADO.Identifier) is
      pragma Unreferenced (Module);

      Ctx   : constant Services.Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      DB    : ADO.Sessions.Session := AWA.Services.Contexts.Get_Session (Ctx);
      Found : Boolean;
   begin
      Wiki.Load (DB, Id, Found);
   end Load_Wiki_Space;

   --  ------------------------------
   --  Create the wiki page into the wiki space.
   --  ------------------------------
   procedure Create_Wiki_Page (Model  : in Wiki_Module;
                               Into   : in AWA.Wikis.Models.Wiki_Space_Ref'Class;
                               Page   : in out Awa.Wikis.Models.Wiki_Page_Ref'Class) is
      Ctx   : constant Services.Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      User  : constant ADO.Identifier := Ctx.Get_User_Identifier;
      DB    : ADO.Sessions.Master_Session := AWA.Services.Contexts.Get_Master_Session (Ctx);
   begin
      Log.Info ("Create wiki page {0}", String '(Page.Get_Name));

      --  Check that the user has the create wiki page permission on the given wiki space.
      AWA.Permissions.Check (Permission => ACL_Create_Wiki_Pages.Permission,
                             Entity     => Into);

      Ctx.Start;
      Page.Set_Wiki (Into);
      Page.Save (DB);
      Ctx.Commit;
   end Create_Wiki_Page;

   --  ------------------------------
   --  Save the wiki page.
   --  ------------------------------
   procedure Save (Model  : in Wiki_Module;
                   Page   : in out Awa.Wikis.Models.Wiki_Page_Ref'Class) is
      pragma Unreferenced (Model);

      Ctx   : constant Services.Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      DB    : ADO.Sessions.Master_Session := AWA.Services.Contexts.Get_Master_Session (Ctx);
   begin
      --  Check that the user has the create wiki page permission on the given wiki space.
      AWA.Permissions.Check (Permission => ACL_Update_Wiki_Pages.Permission,
                             Entity     => Page);

      Ctx.Start;
      Page.Save (DB);
      Ctx.Commit;
   end Save;

end AWA.Wikis.Modules;
