/* Copied from ado-mysql.sql*/
/* File generated automatically by dynamo */
/* Entity types */
CREATE TABLE entity_type (
  /* the entity type identifier */
  `id` INTEGER  AUTO_INCREMENT,
  /* the entity type name (table name) */
  `name` VARCHAR(127) UNIQUE NOT NULL,
  PRIMARY KEY (`id`)
);
/* Sequence generator */
CREATE TABLE sequence (
  /* the sequence name */
  `name` VARCHAR(127) NOT NULL,
  /* the sequence record version */
  `version` int ,
  /* the sequence value */
  `value` BIGINT ,
  /* the sequence block size */
  `block_size` BIGINT ,
  PRIMARY KEY (`name`)
);
INSERT INTO entity_type (name) VALUES
("entity_type")
,("sequence")
;
/* Copied from awa-mysql.sql*/
/* File generated automatically by dynamo */
/*  */
CREATE TABLE awa_message (
  /* the message identifier */
  `id` BIGINT NOT NULL,
  /* the message creation date */
  `create_date` DATETIME NOT NULL,
  /* the message priority */
  `priority` INTEGER NOT NULL,
  /* the message count */
  `count` INTEGER NOT NULL,
  /* the message parameters */
  `parameters` VARCHAR(255) BINARY NOT NULL,
  /* the server identifier which processes the message */
  `server_id` INTEGER NOT NULL,
  /* the task identfier on the server which processes the message */
  `task_id` INTEGER NOT NULL,
  /* the message status */
  `status` TINYINT NOT NULL,
  /* the message processing date */
  `processing_date` DATETIME ,
  /*  */
  `version` INTEGER NOT NULL,
  /* the entity identifier to which this event is associated. */
  `entity_id` BIGINT NOT NULL,
  /* the entity type of the entity identifier to which this event is associated. */
  `entity_type` INTEGER NOT NULL,
  /* the date and time when the event was finished to be processed. */
  `finish_date` DATETIME ,
  /*  */
  `queue_id` BIGINT NOT NULL,
  /* the message type */
  `message_type_id` BIGINT NOT NULL,
  /* the optional user who triggered the event message creation */
  `user_id` BIGINT ,
  /* the optional user session that triggered the message creation */
  `session_id` BIGINT ,
  PRIMARY KEY (`id`)
);
/*  */
CREATE TABLE awa_message_type (
  /*  */
  `id` BIGINT NOT NULL,
  /* the message type name */
  `name` VARCHAR(255) BINARY NOT NULL,
  PRIMARY KEY (`id`)
);
/* The message queue tracks the event messages that must be dispatched by
a given server. */
CREATE TABLE awa_queue (
  /*  */
  `id` BIGINT NOT NULL,
  /*  */
  `server_id` INTEGER NOT NULL,
  /* the message queue name */
  `name` VARCHAR(255) BINARY NOT NULL,
  PRIMARY KEY (`id`)
);
/* The application that is granted access to the database.
 */
CREATE TABLE awa_application (
  /* the application identifier. */
  `id` BIGINT NOT NULL,
  /* the application name. */
  `name` VARCHAR(255) BINARY NOT NULL,
  /* the application secret key. */
  `secret_key` VARCHAR(255) BINARY NOT NULL,
  /* the application public identifier. */
  `client_id` VARCHAR(255) BINARY NOT NULL,
  /* the optimistic lock version. */
  `version` INTEGER NOT NULL,
  /* the application create date. */
  `create_date` DATETIME NOT NULL,
  /* the application update date. */
  `update_date` DATETIME NOT NULL,
  /* the application title displayed in the OAuth login form. */
  `title` VARCHAR(255) BINARY NOT NULL,
  /* the application description. */
  `description` VARCHAR(255) BINARY NOT NULL,
  /* the optional login URL. */
  `app_login_url` VARCHAR(255) BINARY NOT NULL,
  /* the application logo URL. */
  `app_logo_url` VARCHAR(255) BINARY NOT NULL,
  /*  */
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/*  */
CREATE TABLE awa_callback (
  /*  */
  `id` BIGINT NOT NULL,
  /*  */
  `url` VARCHAR(255) BINARY NOT NULL,
  /* the optimistic lock version. */
  `version` INTEGER NOT NULL,
  /*  */
  `application_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The session is created when the user has granted an access to an application
or when the application has refreshed its access token. */
CREATE TABLE awa_oauth_session (
  /* the session identifier. */
  `id` BIGINT NOT NULL,
  /* the session creation date. */
  `create_date` DATETIME NOT NULL,
  /* a random salt string to access/request token generation. */
  `salt` VARCHAR(255) BINARY NOT NULL,
  /* the expiration date. */
  `expire_date` DATETIME NOT NULL,
  /* the application that is granted access. */
  `application_id` BIGINT NOT NULL,
  /*  */
  `user_id` BIGINT NOT NULL,
  /*  */
  `session_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The ACL table records permissions which are granted for a user to access a given database entity. */
CREATE TABLE awa_acl (
  /* the ACL identifier */
  `id` BIGINT NOT NULL,
  /* the entity identifier to which the ACL applies */
  `entity_id` BIGINT NOT NULL,
  /* the writeable flag */
  `writeable` TINYINT NOT NULL,
  /*  */
  `user_id` BIGINT NOT NULL,
  /*  */
  `workspace_id` BIGINT NOT NULL,
  /* the entity type concerned by the ACL. */
  `entity_type` INTEGER NOT NULL,
  /* the permission that is granted. */
  `permission` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The permission table lists all the application permissions that are defined.
This is a system table shared by every user and workspace.
The list of permission is fixed and never changes. */
CREATE TABLE awa_permission (
  /* the permission database identifier. */
  `id` BIGINT NOT NULL,
  /* the permission name */
  `name` VARCHAR(255) BINARY NOT NULL,
  PRIMARY KEY (`id`)
);
/*  */
CREATE TABLE awa_access_key (
  /* the secure access key. */
  `access_key` VARCHAR(255) BINARY NOT NULL,
  /* the access key expiration date. */
  `expire_date` DATE NOT NULL,
  /* the access key identifier. */
  `id` BIGINT NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /*  */
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The Email entity defines the user email addresses.
The user has a primary email address that is obtained
from the registration process (either through a form
submission or through OpenID authentication). */
CREATE TABLE awa_email (
  /* the email address. */
  `email` VARCHAR(255) BINARY NOT NULL,
  /* the last mail delivery status (if known). */
  `status` TINYINT NOT NULL,
  /* the date when the last email error was detected. */
  `last_error_date` DATETIME NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /* the email primary key. */
  `id` BIGINT NOT NULL,
  /* the user. */
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/*  */
CREATE TABLE awa_session (
  /*  */
  `start_date` DATETIME NOT NULL,
  /*  */
  `end_date` DATETIME ,
  /*  */
  `ip_address` VARCHAR(255) BINARY NOT NULL,
  /*  */
  `stype` TINYINT NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /*  */
  `server_id` INTEGER NOT NULL,
  /*  */
  `id` BIGINT NOT NULL,
  /*  */
  `auth_id` BIGINT ,
  /*  */
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The User entity represents a user that can access and use the application.
 */
CREATE TABLE awa_user (
  /* the user first name. */
  `first_name` VARCHAR(255) BINARY NOT NULL,
  /* the user last name. */
  `last_name` VARCHAR(255) BINARY NOT NULL,
  /* the user password hash. */
  `password` VARCHAR(255) BINARY NOT NULL,
  /* the user OpenID identifier. */
  `open_id` VARCHAR(255) BINARY NOT NULL,
  /* the user country. */
  `country` VARCHAR(255) BINARY NOT NULL,
  /* the user display name. */
  `name` VARCHAR(255) BINARY NOT NULL,
  /* version number. */
  `version` INTEGER NOT NULL,
  /* the user identifier. */
  `id` BIGINT NOT NULL,
  /* the password salt. */
  `salt` VARCHAR(255) BINARY NOT NULL,
  /*  */
  `email_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_message")
,("awa_message_type")
,("awa_queue")
,("awa_application")
,("awa_callback")
,("awa_oauth_session")
,("awa_acl")
,("awa_permission")
,("awa_access_key")
,("awa_email")
,("awa_session")
,("awa_user")
;
/* Copied from awa_counters-mysql.sql*/
/* File generated automatically by dynamo */
/*  */
CREATE TABLE awa_counter (
  /* the object associated with the counter. */
  `object_id` BIGINT NOT NULL,
  /* the day associated with the counter. */
  `date` DATE NOT NULL,
  /* the counter value. */
  `counter` INTEGER NOT NULL,
  /* the counter definition identifier. */
  `definition_id` BIGINT NOT NULL,
  PRIMARY KEY (`object_id`, `date`, `definition_id`)
);
/* A counter definition defines what the counter represents. It uniquely identifies
the counter for the Counter table. A counter may be associated with a database
table. In that case, the counter definition has a relation to the corresponding Entity_Type. */
CREATE TABLE awa_counter_definition (
  /* the counter name. */
  `name` VARCHAR(255) BINARY NOT NULL,
  /* the counter unique id. */
  `id` INTEGER NOT NULL,
  /* the optional entity type that identifies the database table. */
  `entity_type` INTEGER ,
  PRIMARY KEY (`id`)
);
/*  */
CREATE TABLE awa_visit (
  /* the entity identifier. */
  `object_id` BIGINT NOT NULL,
  /* the number of times the entity was visited by the user. */
  `counter` INTEGER NOT NULL,
  /* the date and time when the entity was last visited. */
  `date` DATETIME NOT NULL,
  /* the user who visited the entity. */
  `user` BIGINT NOT NULL,
  /* the counter definition identifier. */
  `definition_id` BIGINT NOT NULL,
  PRIMARY KEY (`object_id`, `user`, `definition_id`)
);
INSERT INTO entity_type (name) VALUES
("awa_counter")
,("awa_counter_definition")
,("awa_visit")
;
/* Copied from awa-comments-mysql.sql*/
/* File generated automatically by dynamo */
/* The Comment table records a user comment associated with a database entity.
The comment can be associated with any other database record. */
CREATE TABLE awa_comment (
  /* the comment publication date */
  `create_date` DATETIME NOT NULL,
  /* the comment message. */
  `message` TEXT NOT NULL,
  /* the entity identifier to which this comment is associated */
  `entity_id` BIGINT NOT NULL,
  /* the comment identifier */
  `id` BIGINT NOT NULL,
  /* the optimistic lock version. */
  `version` INTEGER NOT NULL,
  /* the entity type that identifies the table to which the comment is associated. */
  `entity_type` INTEGER NOT NULL,
  /* the comment status to decide whether the comment is visible (published) or not. */
  `status` integer NOT NULL,
  /* the comment format type. */
  `format` integer NOT NULL,
  /*  */
  `author_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_comment")
;
/* Copied from awa-workspaces-mysql.sql*/
/* File generated automatically by dynamo */
/*  */
CREATE TABLE awa_invitation (
  /* the invitation identifier. */
  `id` BIGINT NOT NULL,
  /* version optimistic lock. */
  `version` INTEGER NOT NULL,
  /* date when the invitation was created and sent. */
  `create_date` DATETIME NOT NULL,
  /* the email address to which the invitation was sent. */
  `email` VARCHAR(255) BINARY NOT NULL,
  /* the invitation message. */
  `message` text NOT NULL,
  /* the date when the invitation was accepted. */
  `acceptance_date` DATETIME ,
  /* the workspace where the user is invited. */
  `workspace_id` BIGINT NOT NULL,
  /*  */
  `access_key_id` BIGINT ,
  /* the user being invited. */
  `invitee_id` BIGINT ,
  /*  */
  `inviter_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The workspace controls the features available in the application
for a set of users: the workspace members.  A user could create
several workspaces and be part of several workspaces that other
users have created. */
CREATE TABLE awa_workspace (
  /* the workspace identifier */
  `id` BIGINT NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /*  */
  `create_date` DATETIME NOT NULL,
  /*  */
  `owner_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/*  */
CREATE TABLE awa_workspace_feature (
  /*  */
  `id` BIGINT NOT NULL,
  /*  */
  `limit` INTEGER NOT NULL,
  /*  */
  `workspace_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The workspace member indicates the users who
are part of the workspace. */
CREATE TABLE awa_workspace_member (
  /*  */
  `id` BIGINT NOT NULL,
  /* the date when the user has joined the workspace. */
  `join_date` DATETIME ,
  /* the member role. */
  `role` VARCHAR(255) BINARY NOT NULL,
  /*  */
  `member_id` BIGINT NOT NULL,
  /*  */
  `workspace_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_invitation")
,("awa_workspace")
,("awa_workspace_feature")
,("awa_workspace_member")
;
/* Copied from awa-storages-mysql.sql*/
/* File generated automatically by dynamo */
/* The uri member holds the URI if the storage type is URL.

When storage is FILE, the local file path is built by using
the workspace identifier and the storage identifier. */
CREATE TABLE awa_storage (
  /* the storage type which defines where the content is stored */
  `storage` TINYINT NOT NULL,
  /* the storage creation date */
  `create_date` DATETIME NOT NULL,
  /* the file name */
  `name` VARCHAR(255) BINARY NOT NULL,
  /* the file size */
  `file_size` INTEGER NOT NULL,
  /* the mime type */
  `mime_type` VARCHAR(255) BINARY NOT NULL,
  /* the storage URI */
  `uri` VARCHAR(255) BINARY NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /* the storage identifier */
  `id` BIGINT NOT NULL,
  /* whether the document is public or not. */
  `is_public` TINYINT NOT NULL,
  /*  */
  `original_id` BIGINT ,
  /*  */
  `store_data_id` BIGINT ,
  /*  */
  `owner_id` BIGINT NOT NULL,
  /*  */
  `workspace_id` BIGINT NOT NULL,
  /*  */
  `folder_id` BIGINT ,
  PRIMARY KEY (`id`)
);
/* The storage data is created only if the storage type
is set to DATABASE.  It holds the file content in the blob. */
CREATE TABLE awa_storage_data (
  /* the storage data identifier */
  `id` BIGINT NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /* the storage content */
  `data` LONGBLOB NOT NULL,
  PRIMARY KEY (`id`)
);
/*  */
CREATE TABLE awa_storage_folder (
  /* the storage folder identifier */
  `id` BIGINT NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /* the folder creation date */
  `create_date` DATETIME NOT NULL,
  /*  */
  `name` VARCHAR(255) BINARY NOT NULL,
  /*  */
  `workspace_id` BIGINT NOT NULL,
  /*  */
  `owner_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The local store record is created when a copy of the data is needed on the local file system.
The creation date refers to the date when the data was copied to the local file system.
The expiration date indicates a date after which the local file can be removed
from the local file system. */
CREATE TABLE awa_store_local (
  /* the local store identifier */
  `id` BIGINT NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /*  */
  `store_version` INTEGER NOT NULL,
  /* the shared flag which indicates whether this local store can be shared by several clients. */
  `shared` TINYINT NOT NULL,
  /* the local store path */
  `path` VARCHAR(255) BINARY NOT NULL,
  /* the local store expiration date */
  `expire_date` DATE NOT NULL,
  /* the creation date */
  `create_date` DATETIME NOT NULL,
  /*  */
  `storage_id` BIGINT ,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_storage")
,("awa_storage_data")
,("awa_storage_folder")
,("awa_store_local")
;
/* Copied from awa-tags-mysql.sql*/
/* File generated automatically by dynamo */
/* The tag definition. */
CREATE TABLE awa_tag (
  /* the tag identifier */
  `id` BIGINT NOT NULL,
  /* the tag name */
  `name` VARCHAR(255) BINARY NOT NULL,
  PRIMARY KEY (`id`)
);
/*  */
CREATE TABLE awa_tagged_entity (
  /* the tag entity identifier */
  `id` BIGINT NOT NULL,
  /* Title: Tag model
Date: 2013-02-23the database entity to which the tag is associated */
  `for_entity_id` BIGINT NOT NULL,
  /* the entity type */
  `entity_type` INTEGER NOT NULL,
  /*  */
  `tag_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_tag")
,("awa_tagged_entity")
;
/* Copied from awa-images-mysql.sql*/
/* File generated automatically by dynamo */
/* - The workspace contains one or several folders.
- Each image folder contains a set of images that have been uploaded by the user.
- An image can be visible if a user has an ACL permission to read the associated folder.
- An image marked as 'public=True' can be visible by anybody
 */
CREATE TABLE awa_image (
  /* the image identifier */
  `id` BIGINT NOT NULL,
  /* the image width */
  `width` INTEGER NOT NULL,
  /* the image height */
  `height` INTEGER NOT NULL,
  /* the thumbnail width */
  `thumb_width` INTEGER NOT NULL,
  /* the thumbnail height */
  `thumb_height` INTEGER NOT NULL,
  /*  */
  `path` VARCHAR(255) BINARY NOT NULL,
  /*  */
  `public` TINYINT NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /*  */
  `thumbnail_id` BIGINT ,
  /*  */
  `folder_id` BIGINT NOT NULL,
  /*  */
  `owner_id` BIGINT NOT NULL,
  /*  */
  `storage_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_image")
;
/* Copied from awa-settings-mysql.sql*/
/* File generated automatically by dynamo */
/* The global setting holds some generic
application configuration parameter
which can be stored in the database.

The global setting can be specific to a server. */
CREATE TABLE awa_global_setting (
  /* the global setting identifier. */
  `id` BIGINT NOT NULL,
  /* the global setting value. */
  `value` VARCHAR(255) BINARY NOT NULL,
  /* the global setting optimistic lock version. */
  `version` INTEGER NOT NULL,
  /* the server to which this global setting applies. */
  `server_id` INTEGER NOT NULL,
  /* the setting that corresponds to this global setting. */
  `setting_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The setting table defines all the possible settings
that an application manages.  This table is automatically
populated when an application starts. It is not modified.
 */
CREATE TABLE awa_setting (
  /* the setting identifier. */
  `id` BIGINT NOT NULL,
  /* the setting name. */
  `name` VARCHAR(255) BINARY NOT NULL,
  PRIMARY KEY (`id`)
);
/* The user setting holds the setting value for a given user.
It is created the first time a user changes the default
setting value. It is updated when the user modifies the setting.

 */
CREATE TABLE awa_user_setting (
  /* the user setting identifier. */
  `id` BIGINT NOT NULL,
  /* the setting value. */
  `value` VARCHAR(255) BINARY NOT NULL,
  /* the setting optimistic lock version. */
  `version` INTEGER NOT NULL,
  /* the setting that correspond to the value. */
  `setting_id` BIGINT NOT NULL,
  /* the user to which the setting value is associated. */
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_global_setting")
,("awa_setting")
,("awa_user_setting")
;
/* Copied from awa-votes-mysql.sql*/
/* File generated automatically by dynamo */
/*  */
CREATE TABLE awa_rating (
  /* the rating identifier */
  `id` BIGINT NOT NULL,
  /* the rating taking into account all votes */
  `rating` INTEGER NOT NULL,
  /* the number of votes */
  `vote_count` INTEGER NOT NULL,
  /*  */
  `for_entity_id` BIGINT NOT NULL,
  /* the entity type */
  `for_entity_type` INTEGER NOT NULL,
  PRIMARY KEY (`id`)
);
/* The vote table tracks a vote action by a user on a given database entity.
The primary key is made of the user, the entity id and entity type.
 */
CREATE TABLE awa_vote (
  /*  */
  `rating` INTEGER NOT NULL,
  /*  */
  `entity_id` BIGINT NOT NULL,
  /*  */
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`entity_id`, `user_id`)
);
INSERT INTO entity_type (name) VALUES
("awa_rating")
,("awa_vote")
;
/* Copied from awa-jobs-mysql.sql*/
/* File generated automatically by dynamo */
/* The job is associated with a dispatching queue. */
CREATE TABLE awa_job (
  /* the job identifier */
  `id` BIGINT NOT NULL,
  /* the job status */
  `status` TINYINT NOT NULL,
  /* the job name */
  `name` VARCHAR(255) BINARY NOT NULL,
  /* the job start date */
  `start_date` DATETIME ,
  /* the job creation date */
  `create_date` DATETIME NOT NULL,
  /* the job finish date */
  `finish_date` DATETIME ,
  /* the job progress indicator */
  `progress` INTEGER NOT NULL,
  /* the job parameters */
  `parameters` TEXT NOT NULL,
  /* the job result */
  `results` TEXT NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /* the job priority */
  `priority` INTEGER NOT NULL,
  /*  */
  `user_id` BIGINT ,
  /*  */
  `event_id` BIGINT ,
  /*  */
  `session_id` BIGINT ,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_job")
;
/* Copied from awa-countries-mysql.sql*/
/* File generated automatically by dynamo */
/*  */
CREATE TABLE awa_city (
  /* the city identifier */
  `id` BIGINT NOT NULL,
  /* the city name */
  `name` VARCHAR(255) BINARY NOT NULL,
  /* the city ZIP code */
  `zip_code` INTEGER NOT NULL,
  /* the city latitude */
  `latitude` INTEGER NOT NULL,
  /* the city longitude */
  `longitude` INTEGER NOT NULL,
  /* the region that this city belongs to */
  `region_id` BIGINT NOT NULL,
  /* the country that this city belongs to */
  `country_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The country model is a system data model for the application.
In theory, it never changes. */
CREATE TABLE awa_country (
  /* the country identifier */
  `id` BIGINT NOT NULL,
  /* the country name */
  `name` VARCHAR(255) BINARY NOT NULL,
  /* the continent name */
  `continent` VARCHAR(255) BINARY NOT NULL,
  /* the currency used in the country */
  `currency` VARCHAR(255) BINARY NOT NULL,
  /* the country ISO code */
  `iso_code` VARCHAR(255) BINARY NOT NULL,
  /* the country geoname id */
  `geonameid` INTEGER NOT NULL,
  /* the country main language */
  `languages` VARCHAR(255) BINARY NOT NULL,
  /* the TLD associated with this country */
  `tld` VARCHAR(3) BINARY NOT NULL,
  /* the currency code */
  `currency_code` VARCHAR(3) BINARY NOT NULL,
  PRIMARY KEY (`id`)
);
/* The country neighbor defines what countries
are neigbors with each other */
CREATE TABLE awa_country_neighbor (
  /*  */
  `id` BIGINT NOT NULL,
  /*  */
  `neighbor_of_id` BIGINT NOT NULL,
  /*  */
  `neighbor_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* Region defines an area within a country. */
CREATE TABLE awa_region (
  /* the region identifier */
  `id` BIGINT NOT NULL,
  /* the region name */
  `name` VARCHAR(255) BINARY NOT NULL,
  /* the region geonameid */
  `geonameid` INTEGER NOT NULL,
  /* the country that this region belongs to */
  `country_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_city")
,("awa_country")
,("awa_country_neighbor")
,("awa_region")
;
/* Copied from awa-questions-mysql.sql*/
/* File generated automatically by dynamo */
/* The answer table gives a list of anwsers to the question.
Ranking is updating according to users voting for the anwser.
 */
CREATE TABLE awa_answer (
  /* the answer creation date. */
  `create_date` DATETIME NOT NULL,
  /* the date when the answer was edited. */
  `edit_date` DATETIME ,
  /* the answer text. */
  `answer` TEXT NOT NULL,
  /* the anwser rank number. */
  `rank` INTEGER NOT NULL,
  /* the answer identifier. */
  `id` BIGINT NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /* the user who wrote the answer. */
  `author_id` BIGINT NOT NULL,
  /*  */
  `question_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The question table holds a single question asked by a user to the community.
The short description is used to give an overview of the question in long lists
while the description contains the full question text.  The rating is updating
according to users voting for the question. */
CREATE TABLE awa_question (
  /* the date when the question was created. */
  `create_date` DATETIME NOT NULL,
  /* the question title. */
  `title` VARCHAR(255) BINARY NOT NULL,
  /* the full description. */
  `description` TEXT NOT NULL,
  /* the date when the question was edited. */
  `edit_date` DATETIME ,
  /* Title: Questions and Answers model
Date: 2015-11-15
the question short description. */
  `short_description` VARCHAR(255) BINARY NOT NULL,
  /* the question rating. */
  `rating` INTEGER NOT NULL,
  /* the question identifier. */
  `id` BIGINT NOT NULL,
  /* the optimistic locking version. */
  `version` INTEGER NOT NULL,
  /* the user who asked the question. */
  `author_id` BIGINT NOT NULL,
  /*  */
  `workspace_id` BIGINT NOT NULL,
  /*  */
  `accepted_answer_id` BIGINT ,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_answer")
,("awa_question")
;
/* Copied from awa-blogs-mysql.sql*/
/* File generated automatically by dynamo */
/*  */
CREATE TABLE awa_blog (
  /* the blog identifier */
  `id` BIGINT NOT NULL,
  /* the blog name */
  `name` VARCHAR(255) BINARY NOT NULL,
  /* the version */
  `version` INTEGER NOT NULL,
  /* the blog uuid */
  `uid` VARCHAR(255) BINARY NOT NULL,
  /* the blog creation date */
  `create_date` DATETIME NOT NULL,
  /* the date when the blog was updated */
  `update_date` DATETIME NOT NULL,
  /* The blog base URL. */
  `url` VARCHAR(255) BINARY NOT NULL,
  /* the workspace that this blog belongs to */
  `workspace_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/*  */
CREATE TABLE awa_post (
  /* the post identifier */
  `id` BIGINT NOT NULL,
  /* the post title */
  `title` VARCHAR(255) BINARY NOT NULL,
  /* the post text content */
  `text` TEXT NOT NULL,
  /* the post creation date */
  `create_date` DATETIME NOT NULL,
  /* the post URI */
  `uri` VARCHAR(255) BINARY NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /* the post publication date */
  `publish_date` DATETIME ,
  /* the post status */
  `status` TINYINT NOT NULL,
  /*  */
  `allow_comments` TINYINT NOT NULL,
  /* the number of times the post was read. */
  `read_count` INTEGER NOT NULL,
  /*  */
  `author_id` BIGINT NOT NULL,
  /*  */
  `blog_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_blog")
,("awa_post")
;
/* Copied from awa-changelogs-mysql.sql*/
/* File generated automatically by dynamo */
/*  */
CREATE TABLE awa_changelog (
  /* the changelog identifier. */
  `id` BIGINT NOT NULL,
  /* the changelog date. */
  `date` DATETIME NOT NULL,
  /* the changelog text. */
  `text` VARCHAR(255) BINARY NOT NULL,
  /* the optional entity to which the changelog is associated. */
  `for_entity_id` BIGINT NOT NULL,
  /*  */
  `user_id` BIGINT NOT NULL,
  /*  */
  `entity_type` INTEGER NOT NULL,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_changelog")
;
/* Copied from awa-wikis-mysql.sql*/
/* File generated automatically by dynamo */
/*  */
CREATE TABLE awa_wiki_content (
  /* the wiki page content identifier */
  `id` BIGINT NOT NULL,
  /* the wiki content creation date */
  `create_date` DATETIME NOT NULL,
  /* the wiki text content */
  `content` TEXT NOT NULL,
  /* the format type used used by the wiki content */
  `format` TINYINT NOT NULL,
  /* the content comment string */
  `save_comment` VARCHAR(255) BINARY NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /* the wiki page version */
  `page_version` INTEGER NOT NULL,
  /* the wiki page that this Wiki_Content belongs to */
  `page_id` BIGINT NOT NULL,
  /* the page version author */
  `author_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
/* The wiki page represents a page with its versions.
It refers to the last version which is currently visible.
It has an optional preview image which defines
the thumbnail preview of the last/current wiki content. */
CREATE TABLE awa_wiki_page (
  /* the wiki page identifier */
  `id` BIGINT NOT NULL,
  /* the wiki page name */
  `name` VARCHAR(255) BINARY NOT NULL,
  /* the last page version number */
  `last_version` INTEGER NOT NULL,
  /* whether the wiki page is public */
  `is_public` TINYINT NOT NULL,
  /* the page title */
  `title` VARCHAR(255) BINARY NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /* a read counter which indicates how many times the page was read. */
  `read_count` INTEGER NOT NULL,
  /* the wiki page preview. */
  `preview_id` BIGINT ,
  /* the wiki space that this page belongs to */
  `wiki_id` BIGINT NOT NULL,
  /* the current content (or last version) */
  `content_id` BIGINT ,
  PRIMARY KEY (`id`)
);
/* Permission is granted to display a wiki page if there is
an ACL entry between the wiki space and the user. */
CREATE TABLE awa_wiki_space (
  /* the wiki space identifier */
  `id` BIGINT NOT NULL,
  /* the wiki name */
  `name` VARCHAR(255) BINARY NOT NULL,
  /* whether the wiki is public */
  `is_public` TINYINT NOT NULL,
  /*  */
  `version` INTEGER NOT NULL,
  /* the wiki creation date. */
  `create_date` DATETIME NOT NULL,
  /* the left panel side wiki text for every page. */
  `left_side` TEXT NOT NULL,
  /* the right panel wiki text for every page.
 */
  `right_side` TEXT NOT NULL,
  /* the default wiki page format. */
  `format` TINYINT NOT NULL,
  /*  */
  `workspace_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
);
INSERT INTO entity_type (name) VALUES
("awa_wiki_content")
,("awa_wiki_page")
,("awa_wiki_space")
;
