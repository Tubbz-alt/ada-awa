-----------------------------------------------------------------------
--  awa-storages-services -- Storage service
--  Copyright (C) 2012 Stephane Carrez
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
with Ada.Calendar;

with Util.Log.Loggers;

with ADO.Objects;
with ADO.Queries;
with ADO.Statements;
with ADO.Sessions.Entities;

with AWA.Services.Contexts;
with AWA.Workspaces.Models;
with AWA.Workspaces.Modules;
with AWA.Permissions;
with AWA.Storages.Stores.Files;
package body AWA.Storages.Services is

   use AWA.Services;

   Log : constant Util.Log.Loggers.Logger := Util.Log.Loggers.Create ("AWA.Storages.Services");

   --  ------------------------------
   --  Get the persistent store that manages the data store identified by <tt>Kind</tt>.
   --  ------------------------------
   function Get_Store (Service : in Storage_Service;
                       Kind    : in AWA.Storages.Models.Storage_Type)
                       return AWA.Storages.Stores.Store_Access is
   begin
      return Service.Stores (Kind);
   end Get_Store;

   --  ------------------------------
   --  Initializes the storage service.
   --  ------------------------------
   overriding
   procedure Initialize (Service : in out Storage_Service;
                         Module  : in AWA.Modules.Module'Class) is
      Root : constant String := Module.Get_Config (Stores.Files.Root_Directory_Parameter.P);
      Tmp  : constant String := Module.Get_Config (Stores.Files.Tmp_Directory_Parameter.P);
   begin
      AWA.Modules.Module_Manager (Service).Initialize (Module);
      Service.Stores (Storages.Models.DATABASE) := Service.Database_Store'Unchecked_Access;
      Service.Stores (Storages.Models.FILE) := AWA.Storages.Stores.Files.Create_File_Store (Root);
      Service.Stores (Storages.Models.TMP) := AWA.Storages.Stores.Files.Create_File_Store (Tmp);
      Service.Database_Store.Tmp := Service.Stores (Storages.Models.TMP);
   end Initialize;

   --  ------------------------------
   --  Create or save the folder.
   --  ------------------------------
   procedure Save_Folder (Service : in Storage_Service;
                          Folder  : in out AWA.Storages.Models.Storage_Folder_Ref'Class) is
      pragma Unreferenced (Service);

      Ctx       : constant Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      DB        : ADO.Sessions.Master_Session := AWA.Services.Contexts.Get_Master_Session (Ctx);
      Workspace : AWA.Workspaces.Models.Workspace_Ref;
   begin
      if not Folder.Is_Null then
         Workspace := AWA.Workspaces.Models.Workspace_Ref (Folder.Get_Workspace);
      end if;
      if Workspace.Is_Null then
         AWA.Workspaces.Modules.Get_Workspace (DB, Ctx, Workspace);
         Folder.Set_Workspace (Workspace);
      end if;

      --  Check that the user has the create folder permission on the given workspace.
      AWA.Permissions.Check (Permission => ACL_Create_Folder.Permission,
                             Entity     => Workspace.Get_Id);

      Ctx.Start;
      if not Folder.Is_Inserted then
         Folder.Set_Create_Date (Ada.Calendar.Clock);
      end if;
      Folder.Save (DB);
      Ctx.Commit;
   end Save_Folder;

   --  ------------------------------
   --  Load the folder instance identified by the given identifier.
   --  ------------------------------
   procedure Load_Folder (Service : in Storage_Service;
                          Folder  : in out AWA.Storages.Models.Storage_Folder_Ref'Class;
                          Id      : in ADO.Identifier) is
      pragma Unreferenced (Service);

      Ctx       : constant Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      DB        : ADO.Sessions.Master_Session := AWA.Services.Contexts.Get_Master_Session (Ctx);
   begin
      Folder.Load (Session => DB, Id => Id);
   end Load_Folder;

   --  ------------------------------
   --  Save the data object contained in the <b>Data</b> part element into the
   --  target storage represented by <b>Into</b>.
   --  ------------------------------
   procedure Save (Service : in Storage_Service;
                   Into    : in out AWA.Storages.Models.Storage_Ref'Class;
                   Data    : in ASF.Parts.Part'Class;
                   Storage : in AWA.Storages.Models.Storage_Type) is
   begin
      Storage_Service'Class (Service).Save (Into, Data.Get_Local_Filename, Storage);
   end Save;

   --  ------------------------------
   --  Save the file pointed to by the <b>Path</b> string in the storage
   --  object represented by <b>Into</b> and managed by the storage service.
   --  ------------------------------
   procedure Save (Service : in Storage_Service;
                   Into    : in out AWA.Storages.Models.Storage_Ref'Class;
                   Path    : in String;
                   Storage : in AWA.Storages.Models.Storage_Type) is
      use type AWA.Storages.Models.Storage_Type;
      use type Stores.Store_Access;

      Ctx       : constant Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      DB        : ADO.Sessions.Master_Session := AWA.Services.Contexts.Get_Master_Session (Ctx);
      Workspace : AWA.Workspaces.Models.Workspace_Ref;
      Store     : Stores.Store_Access;
      Created   : Boolean;
   begin
      Log.Info ("Save {0} in storage space", Path);

      Into.Set_Storage (Storage);
      Store := Storage_Service'Class (Service).Get_Store (Into.Get_Storage);
      if Store = null then
         Log.Error ("There is no store for storage {0}", Models.Storage_Type'Image (Storage));
      end if;

      if not Into.Is_Null then
         Workspace := AWA.Workspaces.Models.Workspace_Ref (Into.Get_Workspace);
      end if;
      if Workspace.Is_Null then
         AWA.Workspaces.Modules.Get_Workspace (DB, Ctx, Workspace);
         Into.Set_Workspace (Workspace);
      end if;

      --  Check that the user has the create storage permission on the given workspace.
      AWA.Permissions.Check (Permission => ACL_Create_Storage.Permission,
                             Entity     => Workspace.Get_Id);

      Ctx.Start;
      Created := not Into.Is_Inserted;
      if Created then
         Into.Set_Create_Date (Ada.Calendar.Clock);
         Into.Set_Owner (Ctx.Get_User);
      end if;
      Into.Save (DB);
      Store.Save (DB, Into, Path);
      Into.Save (DB);

      --  Notify the listeners.
      if Created then
         Storage_Lifecycle.Notify_Create (Service, Into);
      else
         Storage_Lifecycle.Notify_Update (Service, Into);
      end if;
      Ctx.Commit;
   end Save;

   --  ------------------------------
   --  Load the storage content identified by <b>From</b> into the blob descriptor <b>Into</b>.
   --  Raises the <b>NOT_FOUND</b> exception if there is no such storage.
   --  ------------------------------
   procedure Load (Service : in Storage_Service;
                   From    : in ADO.Identifier;
                   Name    : out Ada.Strings.Unbounded.Unbounded_String;
                   Mime    : out Ada.Strings.Unbounded.Unbounded_String;
                   Date    : out Ada.Calendar.Time;
                   Into    : out ADO.Blob_Ref) is
      use type AWA.Storages.Models.Storage_Type;
      use type AWA.Storages.Stores.Store_Access;

      Ctx   : constant Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      User  : constant ADO.Identifier := Ctx.Get_User_Identifier;
      DB    : ADO.Sessions.Session := AWA.Services.Contexts.Get_Session (Ctx);
      Query : ADO.Statements.Query_Statement
        := DB.Create_Statement (Models.Query_Storage_Get_Data);
      Kind  : AWA.Storages.Models.Storage_Type;
   begin
      Query.Bind_Param ("store_id", From);
      Query.Bind_Param ("user_id", User);
      ADO.Sessions.Entities.Bind_Param (Query, "table",
                                        AWA.Workspaces.Models.WORKSPACE_TABLE'Access, DB);

      Query.Execute;
      if not Query.Has_Elements then
         Log.Warn ("Storage entity {0} not found", ADO.Identifier'Image (From));
         raise ADO.Objects.NOT_FOUND;
      end if;
      Mime := Query.Get_Unbounded_String (0);
      Date := Query.Get_Time (1);
      Name := Query.Get_Unbounded_String (2);
      Kind := AWA.Storages.Models.Storage_Type'Val (Query.Get_Integer (4));
      if Kind = AWA.Storages.Models.DATABASE then
         Into := Query.Get_Blob (5);
      else
         declare
            Store   : Stores.Store_Access;
            Storage : AWA.Storages.Models.Storage_Ref;
            File    : AWA.Storages.Storage_File;
            Found   : Boolean;
         begin
            Store := Storage_Service'Class (Service).Get_Store (Kind);
            if Store = null then
               Log.Error ("There is no store for storage {0}", Models.Storage_Type'Image (Kind));
            end if;
            Storage.Load (DB, From, Found);
            if not Found then
               Log.Warn ("Storage entity {0} not found", ADO.Identifier'Image (From));
               raise ADO.Objects.NOT_FOUND;
            end if;
            Store.Load (DB, Storage, File);
            Into := ADO.Create_Blob (AWA.Storages.Get_Path (File));
         end;
      end if;
   end Load;

   --  Load the storage content into a file.  If the data is not stored in a file, a temporary
   --  file is created with the data content fetched from the store (ex: the database).
   --  The `Mode` parameter indicates whether the file will be read or written.
   --  The `Expire` parameter allows to control the expiration of the temporary file.
   procedure Get_Local_File (Service : in Storage_Service;
                             From    : in ADO.Identifier;
                             Mode    : in Read_Mode := READ;
                             Into    : out Storage_File) is
      use type Stores.Store_Access;
      use type Models.Storage_Type;

      Ctx     : constant Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      User    : constant ADO.Identifier := Ctx.Get_User_Identifier;
      DB      : ADO.Sessions.Master_Session := AWA.Services.Contexts.Get_Master_Session (Ctx);
      Query   : ADO.Queries.Context;
      Found   : Boolean;
      Storage : AWA.Storages.Models.Storage_Ref;
      Local   : AWA.Storages.Models.Store_Local_Ref;
      Store   : Stores.Store_Access;
   begin
      if Mode = READ then
         Query.Set_Query (AWA.Storages.Models.Query_Storage_Get_Local);
         Query.Bind_Param ("store_id", From);
         Query.Bind_Param ("user_id", User);
         ADO.Sessions.Entities.Bind_Param (Query, "table",
                                           AWA.Workspaces.Models.WORKSPACE_TABLE'Access, DB);
         Local.Find (DB, Query, Found);
         if Found then
            Into.Path := Local.Get_Path;
            return;
         end if;
      end if;

      Query.Set_Query (AWA.Storages.Models.Query_Storage_Get_Storage);
      Query.Bind_Param ("store_id", From);
      Query.Bind_Param ("user_id", User);
      ADO.Sessions.Entities.Bind_Param (Query, "table",
                                        AWA.Workspaces.Models.WORKSPACE_TABLE'Access, DB);
      Storage.Find (DB, Query, Found);
      if not Found then
         raise ADO.Objects.NOT_FOUND;
      end if;

      Ctx.Start;
      Store := Storage_Service'Class (Service).Get_Store (Storage.Get_Storage);
      Store.Load (Session => DB,
                  From    => Storage,
                  Into    => Into);
      Ctx.Commit;
   end Get_Local_File;

   procedure Create_Local_File (Service : in Storage_Service;
                                Into    : out Storage_File) is
   begin
      null;
   end Create_Local_File;

   --  ------------------------------
   --  Deletes the storage instance.
   --  ------------------------------
   procedure Delete (Service : in Storage_Service;
                     Storage : in out AWA.Storages.Models.Storage_Ref'Class) is
      Ctx : constant Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      DB  : ADO.Sessions.Master_Session := AWA.Services.Contexts.Get_Master_Session (Ctx);
      Id  : constant ADO.Identifier := ADO.Objects.Get_Value (Storage.Get_Key);
   begin
      Log.Info ("Delete storage {0}", ADO.Identifier'Image (Id));

      --  Check that the user has the delete storage permission on the given workspace.
      AWA.Permissions.Check (Permission => ACL_Delete_Storage.Permission,
                             Entity     => Id);

      Ctx.Start;
      Storage_Lifecycle.Notify_Delete (Service, Storage);
      Storage.Delete (DB);
      Ctx.Commit;
   end Delete;

   --  ------------------------------
   --  Deletes the storage instance.
   --  ------------------------------
   procedure Delete (Service : in Storage_Service;
                     Storage : in ADO.Identifier) is
      use type Stores.Store_Access;

      Ctx  : constant Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      DB   : ADO.Sessions.Master_Session := AWA.Services.Contexts.Get_Master_Session (Ctx);
      S    : AWA.Storages.Models.Storage_Ref;
      Query : ADO.Statements.Query_Statement
        := DB.Create_Statement (AWA.Storages.Models.Query_Storage_Delete_Local);
      Store : Stores.Store_Access;
   begin
      Log.Info ("Delete storage {0}", ADO.Identifier'Image (Storage));

      --  Check that the user has the delete storage permission on the given workspace.
      AWA.Permissions.Check (Permission => ACL_Delete_Storage.Permission,
                             Entity     => Storage);

      Ctx.Start;
      S.Load (Id => Storage, Session => DB);

      Store := Storage_Service'Class (Service).Get_Store (S.Get_Storage);
      if Store = null then
         Log.Error ("There is no store associated with storage item {0}",
                    ADO.Identifier'Image (Storage));
      else
         Store.Delete (DB, S);
      end if;

      Storage_Lifecycle.Notify_Delete (Service, S);

      --  Delete the storage instance and all storage that refer to it.
      declare
         Stmt : ADO.Statements.Delete_Statement
           := DB.Create_Statement (AWA.Storages.Models.STORAGE_TABLE'Access);
      begin
         Stmt.Set_Filter (Filter => "id = ? OR original_id = ?");
         Stmt.Add_Param (Value => Storage);
         Stmt.Add_Param (Value => Storage);
         Stmt.Execute;
      end;
      --  Delete the local storage instances.
      Query.Bind_Param ("store_id", Storage);
      Query.Execute;
      S.Delete (DB);
      Ctx.Commit;
   end Delete;

end AWA.Storages.Services;
