-----------------------------------------------------------------------
--  awa-blogs-beans -- Beans for blog module
--  Copyright (C) 2011 Stephane Carrez
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
with AWA.Blogs.Services;

with ADO.Queries;
with ADO.Sessions;
with ADO.Sessions.Entities;

with ASF.Contexts.Faces;
with ASF.Applications.Messages.Factory;
with ASF.Events.Faces.Actions;
package body AWA.Blogs.Beans is

   use Ada.Strings.Unbounded;

   BLOG_ID_PARAMETER : constant String := "blog_id";
   POST_ID_PARAMETER : constant String := "post_id";

   --  ------------------------------
   --  Get the parameter identified by the given name and return it as an identifier.
   --  Returns NO_IDENTIFIER if the parameter does not exist or is not valid.
   --  ------------------------------
   function Get_Parameter (Name : in String) return ADO.Identifier is
      Ctx  : constant ASF.Contexts.Faces.Faces_Context_Access := ASF.Contexts.Faces.Current;
      P    : constant String := Ctx.Get_Parameter (Name);
   begin
      if P = "" then
         return ADO.NO_IDENTIFIER;
      else
         return ADO.Identifier'Value (P);
      end if;
   exception
      when others =>
         return ADO.NO_IDENTIFIER;
   end Get_Parameter;

   --  ------------------------------
   --  Get the value identified by the name.
   --  ------------------------------
   overriding
   function Get_Value (From : in Blog_Bean;
                       Name : in String) return Util.Beans.Objects.Object is
   begin
      return AWA.Blogs.Models.Blog_Ref (From).Get_Value (Name);
   end Get_Value;

   --  ------------------------------
   --  Set the value identified by the name.
   --  ------------------------------
   overriding
   procedure Set_Value (From  : in out Blog_Bean;
                        Name  : in String;
                        Value : in Util.Beans.Objects.Object) is
   begin
      if Name = "name" then
         From.Set_Name (Util.Beans.Objects.To_String (Value));
      end if;
   end Set_Value;

   package Create_Blog_Binding is
     new ASF.Events.Faces.Actions.Action_Method.Bind (Bean   => Blog_Bean,
                                                      Method => Create_Blog,
                                                      Name   => "create");

   Blog_Bean_Binding : aliased constant Util.Beans.Methods.Method_Binding_Array
     := (1 => Create_Blog_Binding.Proxy'Access);

   --  This bean provides some methods that can be used in a Method_Expression
   overriding
   function Get_Method_Bindings (From : in Blog_Bean)
                                 return Util.Beans.Methods.Method_Binding_Array_Access is
      pragma Unreferenced (From);
   begin
      return Blog_Bean_Binding'Access;
   end Get_Method_Bindings;

   overriding
   function Copy (Bean : in Blog_Bean) return Blog_Bean is
      pragma Unreferenced (Bean);
      Ref : Blog_Bean;
   begin
      return Ref;
   end Copy;

   --  ------------------------------
   --  Create a new blog.
   --  ------------------------------
   procedure Create_Blog (Bean    : in out Blog_Bean;
                          Outcome : in out Ada.Strings.Unbounded.Unbounded_String) is
      Manager : constant AWA.Blogs.Services.Blog_Service_Access := Bean.Module.Get_Blog_Manager;
      Result  : ADO.Identifier;
   begin
      Manager.Create_Blog (Workspace_Id => 0,
                           Title        => Bean.Get_Name,
                           Result       => Result);
      Outcome := To_Unbounded_String ("success");

   exception
      when Services.Not_Found =>
         Outcome := To_Unbounded_String ("failure");

         ASF.Applications.Messages.Factory.Add_Message ("users.signup_error_message");
   end Create_Blog;

   --  ------------------------------
   --  Create the Blog_Bean bean instance.
   --  ------------------------------
   function Create_Blog_Bean (Module : in AWA.Blogs.Module.Blog_Module_Access)
                              return Util.Beans.Basic.Readonly_Bean_Access is
      use type ADO.Identifier;

      Blog_Id : constant ADO.Identifier := Get_Parameter (BLOG_ID_PARAMETER);
      Object  : constant Blog_Bean_Access := new Blog_Bean;
      Session : ADO.Sessions.Session := Module.Get_Session;
   begin
      if Blog_Id > 0 then
         Object.Load (Session, Blog_Id);
      end if;
      Object.Module := Module;
      return Object.all'Access;
   end Create_Blog_Bean;

   --  ------------------------------
   --  Example of action method.
   --  ------------------------------
   procedure Create_Post (Bean    : in out Post_Bean;
                          Outcome : in out Ada.Strings.Unbounded.Unbounded_String) is
      use type ADO.Identifier;

      Manager : constant AWA.Blogs.Services.Blog_Service_Access := Bean.Module.Get_Blog_Manager;
      Result  : ADO.Identifier;
      Blog_Id : constant ADO.Identifier := Get_Parameter (BLOG_ID_PARAMETER);
      Post_Id : constant ADO.Identifier := Get_Parameter (POST_ID_PARAMETER);
   begin
      if Post_Id < 0 then
         Manager.Create_Post (Blog_Id => Blog_Id,
                              Title   => Bean.Post.Get_Title,
                              URI     => Bean.Post.Get_URI,
                              Text    => Bean.Post.Get_Text,
                              Result  => Result);
      else
         Manager.Update_Post (Post_Id => Post_Id,
                              Title   => To_String (Bean.Title),
                              Text    => To_String (Bean.Text));
      end if;
      Outcome := To_Unbounded_String ("success");

   exception
      when Services.Not_Found =>
         Outcome := To_Unbounded_String ("failure");

         ASF.Applications.Messages.Factory.Add_Message ("users.signup_error_message");
   end Create_Post;

   package Create_Post_Binding is
     new ASF.Events.Faces.Actions.Action_Method.Bind (Bean   => Post_Bean,
                                                      Method => Create_Post,
                                                      Name   => "create");

   package Save_Post_Binding is
     new ASF.Events.Faces.Actions.Action_Method.Bind (Bean   => Post_Bean,
                                                      Method => Create_Post,
                                                      Name   => "save");

   Post_Bean_Binding : aliased constant Util.Beans.Methods.Method_Binding_Array
     := (1 => Create_Post_Binding.Proxy'Access,
         2 => Save_Post_Binding.Proxy'Access);

   --  ------------------------------
   --  Get the value identified by the name.
   --  ------------------------------
   overriding
   function Get_Value (From : in Post_Bean;
                       Name : in String) return Util.Beans.Objects.Object is
   begin
      if Name = BLOG_ID_ATTR then
         return Util.Beans.Objects.To_Object (Long_Long_Integer (From.Blog_Id));
      elsif Name = POST_ID_ATTR then
         return Util.Beans.Objects.To_Object (Long_Long_Integer (From.Post.Get_Id));
      else
         return From.Post.Get_Value (Name);
      end if;
   end Get_Value;

   --  ------------------------------
   --  Set the value identified by the name.
   --  ------------------------------
   overriding
   procedure Set_Value (From  : in out Post_Bean;
                        Name  : in String;
                        Value : in Util.Beans.Objects.Object) is
   begin
      if Name = BLOG_ID_ATTR then
         From.Blog_Id := ADO.Identifier (Util.Beans.Objects.To_Integer (Value));
      elsif Name = POST_ID_ATTR then
         From.Blog_Id := ADO.Identifier (Util.Beans.Objects.To_Integer (Value));
      elsif Name = POST_TEXT_ATTR then
         From.Post.Set_Text (Util.Beans.Objects.To_Unbounded_String (Value));
      elsif Name = POST_TITLE_ATTR then
         From.Post.Set_Title (Util.Beans.Objects.To_Unbounded_String (Value));
      elsif Name = POST_URI_ATTR then
         From.Post.Set_URI (Util.Beans.Objects.To_Unbounded_String (Value));
      end if;
   end Set_Value;

   --  ------------------------------
   --  This bean provides some methods that can be used in a Method_Expression
   --  ------------------------------
   overriding
   function Get_Method_Bindings (From : in Post_Bean)
                                 return Util.Beans.Methods.Method_Binding_Array_Access is
      pragma Unreferenced (From);
   begin
      return Post_Bean_Binding'Access;
   end Get_Method_Bindings;

   --  ------------------------------
   --  Create the Workspaces_Bean bean instance.
   --  ------------------------------
   function Create_Post_Bean (Module : in AWA.Blogs.Module.Blog_Module_Access)
                              return Util.Beans.Basic.Readonly_Bean_Access is
      use type ADO.Identifier;

      Object  : constant Post_Bean_Access := new Post_Bean;
      Post_Id : constant ADO.Identifier := Get_Parameter (POST_ID_PARAMETER);
   begin
      if Post_Id > 0 then
         declare
            Session : ADO.Sessions.Session := Module.Get_Session;
         begin
            Object.Post.Load (Session, Post_Id);
            Object.Title := Object.Post.Get_Title;
            Object.Text  := Object.Post.Get_Text;
            Object.URI   := Object.Post.Get_URI;
         end;
      end if;
      Object.Module := Module;
      return Object.all'Access;
   end Create_Post_Bean;

   --  ------------------------------
   --  Create the Post_List_Bean bean instance.
   --  ------------------------------
   function Create_Post_List_Bean (Module : in AWA.Blogs.Module.Blog_Module_Access)
                                   return Util.Beans.Basic.Readonly_Bean_Access is
      use AWA.Blogs.Models;

      Object  : constant Post_Info_List_Bean_Access := new Post_Info_List_Bean;
      Session : ADO.Sessions.Session := Module.Get_Session;
      Query   : ADO.Queries.Context;
   begin
      Query.Set_Query (AWA.Blogs.Models.Query_Blog_Post_List);
      AWA.Blogs.Models.List (Object.all, Session, Query);
      return Object.all'Access;
   end Create_Post_List_Bean;

   --  ------------------------------
   --  Create the Admin_Post_List_Bean bean instance.
   --  ------------------------------
   function Create_Admin_Post_List_Bean (Module : in AWA.Blogs.Module.Blog_Module_Access)
                                         return Util.Beans.Basic.Readonly_Bean_Access is
      use AWA.Blogs.Models;
      use AWA.Services;
      use type ADO.Identifier;

      Ctx   : constant Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      User  : constant ADO.Identifier := Ctx.Get_User_Identifier;

      Object  : constant Admin_Post_Info_List_Bean_Access := new Admin_Post_Info_List_Bean;
      Session : ADO.Sessions.Session := Module.Get_Session;
      Query   : ADO.Queries.Context;
      Blog_Id : constant ADO.Identifier := Get_Parameter (BLOG_ID_PARAMETER);
   begin
      if Blog_Id > 0 then
         Query.Set_Query (AWA.Blogs.Models.Query_Blog_Admin_Post_List);
         Query.Bind_Param ("blog_id", Blog_Id);
         Query.Bind_Param ("user_id", User);
         ADO.Sessions.Entities.Bind_Param (Query, "table",
                                           AWA.Blogs.Models.BLOG_TABLE'Access, Session);
         AWA.Blogs.Models.List (Object.all, Session, Query);
      end if;
      return Object.all'Access;
   end Create_Admin_Post_List_Bean;


   --  ------------------------------
   --  Create the Blog_List_Bean bean instance.
   --  ------------------------------
   function Create_Blog_List_Bean (Module : in AWA.Blogs.Module.Blog_Module_Access)
                                   return Util.Beans.Basic.Readonly_Bean_Access is
      use AWA.Blogs.Models;
      use AWA.Services;
      use type ADO.Identifier;

      Ctx     : constant Contexts.Service_Context_Access := AWA.Services.Contexts.Current;
      User    : constant ADO.Identifier := Ctx.Get_User_Identifier;
      Object  : constant Blog_Info_List_Bean_Access := new Blog_Info_List_Bean;
      Session : ADO.Sessions.Session := Module.Get_Session;
      Query   : ADO.Queries.Context;
   begin
      Query.Set_Query (AWA.Blogs.Models.Query_Blog_List);
      Query.Bind_Param ("user_id", User);
      ADO.Sessions.Entities.Bind_Param (Query, "table",
                                        AWA.Blogs.Models.BLOG_TABLE'Access, Session);
      AWA.Blogs.Models.List (Object.all, Session, Query);
      return Object.all'Access;
   end Create_Blog_List_Bean;

end AWA.Blogs.Beans;
