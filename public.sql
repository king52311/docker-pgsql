/*
 Navicat Premium Data Transfer

 Source Server         : 81.70.30.64-pgsql
 Source Server Type    : PostgreSQL
 Source Server Version : 130023 (130023)
 Source Host           : 81.70.30.64:5432
 Source Catalog        : findme_db
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 130023 (130023)
 File Encoding         : 65001

 Date: 19/05/2026 09:05:47
*/


-- ----------------------------
-- Type structure for asset_status_enum
-- ----------------------------
DROP TYPE IF EXISTS "public"."asset_status_enum";
CREATE TYPE "public"."asset_status_enum" AS ENUM (
  'active',
  'archived',
  'deleted'
);
ALTER TYPE "public"."asset_status_enum" OWNER TO "findme_user";
COMMENT ON TYPE "public"."asset_status_enum" IS '资产状态：active=有效，archived=归档，deleted=软删除';

-- ----------------------------
-- Type structure for asset_type_enum
-- ----------------------------
DROP TYPE IF EXISTS "public"."asset_type_enum";
CREATE TYPE "public"."asset_type_enum" AS ENUM (
  'item',
  'event'
);
ALTER TYPE "public"."asset_type_enum" OWNER TO "findme_user";
COMMENT ON TYPE "public"."asset_type_enum" IS '资产类型：item=物品，event=事件';

-- ----------------------------
-- Type structure for media_type_enum
-- ----------------------------
DROP TYPE IF EXISTS "public"."media_type_enum";
CREATE TYPE "public"."media_type_enum" AS ENUM (
  'image',
  'audio',
  'video',
  'text',
  'file'
);
ALTER TYPE "public"."media_type_enum" OWNER TO "findme_user";
COMMENT ON TYPE "public"."media_type_enum" IS '媒体类型：image/audio/video/text/file';

-- ----------------------------
-- Type structure for modality_enum
-- ----------------------------
DROP TYPE IF EXISTS "public"."modality_enum";
CREATE TYPE "public"."modality_enum" AS ENUM (
  'photo',
  'voice',
  'text',
  'mixed'
);
ALTER TYPE "public"."modality_enum" OWNER TO "findme_user";
COMMENT ON TYPE "public"."modality_enum" IS '录入模态：photo=拍照，voice=语音，text=文字，mixed=混合';

-- ----------------------------
-- Type structure for tag_source_enum
-- ----------------------------
DROP TYPE IF EXISTS "public"."tag_source_enum";
CREATE TYPE "public"."tag_source_enum" AS ENUM (
  'ai',
  'manual',
  'system'
);
ALTER TYPE "public"."tag_source_enum" OWNER TO "findme_user";
COMMENT ON TYPE "public"."tag_source_enum" IS '标签来源：ai=模型生成，manual=手动，system=系统规则';

-- ----------------------------
-- Type structure for vector
-- ----------------------------
DROP TYPE IF EXISTS "public"."vector";
CREATE TYPE "public"."vector" (
  INPUT = "public"."vector_in",
  OUTPUT = "public"."vector_out",
  RECEIVE = "public"."vector_recv",
  SEND = "public"."vector_send",
  TYPMOD_IN = "public"."vector_typmod_in",
  INTERNALLENGTH = VARIABLE,
  STORAGE = extended,
  CATEGORY = U,
  DELIMITER = ','
);
ALTER TYPE "public"."vector" OWNER TO "postgres";

-- ----------------------------
-- Table structure for asset_classification_feedback
-- ----------------------------
DROP TABLE IF EXISTS "public"."asset_classification_feedback";
CREATE TABLE "public"."asset_classification_feedback" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "asset_id" uuid NOT NULL,
  "user_id" uuid NOT NULL,
  "old_type" "public"."asset_type_enum" NOT NULL,
  "new_type" "public"."asset_type_enum" NOT NULL,
  "reason" text COLLATE "pg_catalog"."default",
  "created_at" timestamptz(6) NOT NULL DEFAULT now()
)
;
ALTER TABLE "public"."asset_classification_feedback" OWNER TO "findme_user";
COMMENT ON COLUMN "public"."asset_classification_feedback"."id" IS '反馈ID';
COMMENT ON COLUMN "public"."asset_classification_feedback"."asset_id" IS '资产ID';
COMMENT ON COLUMN "public"."asset_classification_feedback"."user_id" IS '反馈用户ID';
COMMENT ON COLUMN "public"."asset_classification_feedback"."old_type" IS '原分类';
COMMENT ON COLUMN "public"."asset_classification_feedback"."new_type" IS '修正后分类';
COMMENT ON COLUMN "public"."asset_classification_feedback"."reason" IS '修正原因';
COMMENT ON COLUMN "public"."asset_classification_feedback"."created_at" IS '创建时间';
COMMENT ON TABLE "public"."asset_classification_feedback" IS '资产分类纠错反馈表(用于训练迭代)';

-- ----------------------------
-- Records of asset_classification_feedback
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for asset_media
-- ----------------------------
DROP TABLE IF EXISTS "public"."asset_media";
CREATE TABLE "public"."asset_media" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "asset_id" uuid NOT NULL,
  "media_type" "public"."media_type_enum" NOT NULL,
  "storage_provider" varchar(32) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'oss'::character varying,
  "bucket_name" varchar(128) COLLATE "pg_catalog"."default",
  "object_key" varchar(512) COLLATE "pg_catalog"."default",
  "media_url" text COLLATE "pg_catalog"."default",
  "mime_type" varchar(100) COLLATE "pg_catalog"."default",
  "file_size" int8,
  "width" int4,
  "height" int4,
  "duration_ms" int4,
  "checksum" varchar(128) COLLATE "pg_catalog"."default",
  "sort_order" int4 NOT NULL DEFAULT 0,
  "ocr_text" text COLLATE "pg_catalog"."default",
  "asr_text" text COLLATE "pg_catalog"."default",
  "ai_meta" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "created_at" timestamptz(6) NOT NULL DEFAULT now()
)
;
ALTER TABLE "public"."asset_media" OWNER TO "findme_user";
COMMENT ON COLUMN "public"."asset_media"."id" IS '媒体ID';
COMMENT ON COLUMN "public"."asset_media"."asset_id" IS '关联资产ID';
COMMENT ON COLUMN "public"."asset_media"."media_type" IS '媒体类型';
COMMENT ON COLUMN "public"."asset_media"."storage_provider" IS '存储提供方(如oss)';
COMMENT ON COLUMN "public"."asset_media"."bucket_name" IS '对象存储桶名称';
COMMENT ON COLUMN "public"."asset_media"."object_key" IS '对象存储Key';
COMMENT ON COLUMN "public"."asset_media"."media_url" IS '媒体访问URL';
COMMENT ON COLUMN "public"."asset_media"."mime_type" IS 'MIME类型';
COMMENT ON COLUMN "public"."asset_media"."file_size" IS '文件大小(字节)';
COMMENT ON COLUMN "public"."asset_media"."width" IS '宽度(像素)';
COMMENT ON COLUMN "public"."asset_media"."height" IS '高度(像素)';
COMMENT ON COLUMN "public"."asset_media"."duration_ms" IS '时长(毫秒)';
COMMENT ON COLUMN "public"."asset_media"."checksum" IS '文件摘要(去重校验)';
COMMENT ON COLUMN "public"."asset_media"."sort_order" IS '排序序号';
COMMENT ON COLUMN "public"."asset_media"."ocr_text" IS 'OCR提取文本';
COMMENT ON COLUMN "public"."asset_media"."asr_text" IS 'ASR提取文本';
COMMENT ON COLUMN "public"."asset_media"."ai_meta" IS 'AI处理元数据(JSON)';
COMMENT ON COLUMN "public"."asset_media"."created_at" IS '创建时间';
COMMENT ON TABLE "public"."asset_media" IS '资产媒体表(图片/语音/视频等)';

-- ----------------------------
-- Records of asset_media
-- ----------------------------
BEGIN;
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('94302a4a-d283-4665-873a-354659364f99', '6ee46eae-9380-4831-b87a-f172e5042333', 'image', 'local', NULL, NULL, 'https://api-findme.snuday.com/api/assets/media/5f37df6a131c44fcac8e8dc678bf81f1.jpg', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"scene": "一张办公桌上的黑色键盘特写，周围有线缆和杂物。"}', '2026-05-14 17:20:56.162199+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('1eef210c-071c-47f2-b9a6-2f7fe7f63bdf', '768ed658-488c-4f39-a1d9-b8e2e886099d', 'image', 'local', NULL, NULL, 'https://api-findme.snuday.com/api/assets/media/b3da6fd1431f49d0b9a60a34ec9b680e.jpg', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"scene": "办公桌上的电源插座和充电设备"}', '2026-05-14 14:54:37.529018+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('ccfa140f-e9a2-4a10-a448-3c0ffc241cc5', 'f6bfbc5f-9e48-4aef-8909-90a1c4c345cd', 'image', 'local', NULL, NULL, 'https://api-findme.snuday.com/api/assets/media/b46470e9e3714a3392b06e9ce1122c69.jpg', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"scene": "办公桌上的电源插座和充电设备"}', '2026-05-14 11:35:31.122951+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('556b6eca-0572-41d5-b373-e3ba3a04d89f', 'd2feaaf6-37db-4f40-b1e4-8adca5caad8b', 'image', 'local', NULL, NULL, 'https://api-findme.snuday.com/api/assets/media/b3c1146f8b9b4c518d1d306a857534b7.jpg', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"scene": "一台笔记本电脑在办公桌上运行代码。"}', '2026-05-14 11:12:23.454029+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('05908b48-5b65-4c12-9a8f-7f55fb255f40', '3c4bc399-9065-4cc9-b969-f12fc8e7c49f', 'audio', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/39e5893f85ff44ffac24113ff0d96dc2.mp3', 'audio/mpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"semantic_meaning": ""}', '2026-05-14 21:39:19.544298+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('09437145-e012-4927-a19e-8fff41404ba9', '05634726-abdd-40c3-9a32-2ef3db023f37', 'audio', 'local', NULL, NULL, 'http://tmp/J3dTSZ72QU764896a479e94a68ad114017cac2bc3415.durationTime=18761.mp3', 'audio/mpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"semantic_meaning": ""}', '2026-05-15 08:43:51.039155+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('6d4d4527-6191-43dd-96c2-7dd15eff4886', '9b0ced64-e56a-4e1b-9f84-fed6822a7b41', 'video', 'local', NULL, NULL, 'http://tmp/uMhMHTQDRsqpdafde5f3980f56163a7d4db033e45b97.webm', 'video/mp4', NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, '{}', '2026-05-15 08:46:14.114465+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('3a203682-7472-4d8a-9112-88750f2c549c', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', 'image', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/3ef5b2dc089f4a0ab69b3302b26e10ba.jpg', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"scene": "一栋现代风格的建筑外部，旁边有道路和树木。"}', '2026-05-15 17:54:49.958018+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('6bcabe1b-6fbd-4760-a15c-d606e623ef9c', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', 'image', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/9d8c88ed96b740c39242bdf4163c049f.jpg', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"scene": "室内房间，摆放着风扇、桌子和杂物。"}', '2026-05-15 18:39:17.52572+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('95f433c7-c4db-4ca7-bacd-5fc8509245b1', '8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', 'image', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/1d61b8f7cebf400ca7405f590f77c7ae.jpg', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"scene": "一个人在窗边用镜子照自己的腹部。"}', '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('ec73dad8-f1e7-4348-89ad-e11ab045c854', '601e35a9-1a59-4394-ac78-c83c048f89e3', 'audio', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/4747c028252742cfa3a58c9c3fc9e366.mp3', 'audio/mpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"semantic_meaning": ""}', '2026-05-15 18:45:23.543196+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('1ef3d97d-ae35-4f6f-8556-c353f7ab4c40', 'ebf7e3b6-8d81-4407-8840-935251683bd2', 'audio', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/a4325dd0a7f24d58990ca2abcede48d5.mp3', 'audio/mpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"semantic_meaning": ""}', '2026-05-15 18:47:02.804136+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('849ab8e9-fa89-48e6-892a-947e9a8d2e0c', '38f80a88-b75a-4d03-bab3-2d34237c4aa3', 'image', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/30215b188c314dad949c8f7dfbff3a73.jpg', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"scene": "一张桌子上放着笔记本电脑、一瓶水和一根线缆。"}', '2026-05-15 18:49:44.999978+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('923e5dd6-8989-4147-887e-ff94ab8a96e5', '38f80a88-b75a-4d03-bab3-2d34237c4aa3', 'video', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/c080ebe2ec334fedb8c418d7cf6e399e.mp4', 'video/mp4', NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, '{}', '2026-05-15 18:49:44.999978+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('b954b94f-bcf5-4c62-aa6c-c90b5a8d7d43', '1fae6a5f-f2b9-4a84-ab96-e74668151273', 'image', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/44308d5a61bf45c2a2d411ce6180d9bb.jpg', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"scene": "床上放着几双袜子，背景是储物架和风扇。"}', '2026-05-15 18:56:17.914977+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('ee6d27e8-8ece-476d-948e-3ecae6b26338', 'c1754a01-2fba-4d66-a058-4cf74620601f', 'audio', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/d3343fba9a0d4f4e88d8a51457aad74f.mp3', 'audio/mpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"semantic_meaning": ""}', '2026-05-15 19:06:11.062644+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('ba8a3dae-d6eb-499e-93bc-7924ed5c18f1', '5c8b71c1-037f-4d3e-9b99-080fcfcc7456', 'image', 'local', NULL, NULL, 'http://tmp/OTf77ZUATlZZ959a85ece47c774dbf7e945993be7e4e.jpg', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"scene": ""}', '2026-05-17 07:22:36.076085+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('1eb51a9e-5cb4-4f98-a73e-63ddf84e18fa', 'f73fc527-22bc-4f6e-9ca8-a24c741c994a', 'image', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/b6f953aea7144940b49b2e1716a8c451.jpg', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"scene": "一部手机放在桌子上，连接着充电线。"}', '2026-05-17 07:23:39.062111+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('57f3accc-218b-4052-bbe1-47a683485baf', 'fabe52c3-75ca-49fb-9352-d2c55900e1b0', 'audio', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/6e0f4b7e52f748bb9b1beefb39874add.mp3', 'audio/mpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"semantic_meaning": ""}', '2026-05-18 21:26:57.329927+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('2171e97c-ca13-4217-84da-24a6c04e6661', '70132d31-bc8c-47f2-929e-1f99bd432fe6', 'audio', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/fd255e5edfd440a4bb089cd691a5f688.mp3', 'audio/mpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"semantic_meaning": ""}', '2026-05-18 23:09:58.967483+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('1ef29a56-44e2-49d6-a087-83a1917a89b1', 'a9092dc5-3960-4cae-bec2-6d1f27765691', 'audio', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/c89b051c435346a9ae589ab690a4adc6.mp3', 'audio/mpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"semantic_meaning": ""}', '2026-05-18 23:11:36.865439+08');
INSERT INTO "public"."asset_media" ("id", "asset_id", "media_type", "storage_provider", "bucket_name", "object_key", "media_url", "mime_type", "file_size", "width", "height", "duration_ms", "checksum", "sort_order", "ocr_text", "asr_text", "ai_meta", "created_at") VALUES ('bcff98a8-1fd6-4aa7-8e63-004125421d7c', '1433e0db-3fd1-49f5-94ac-25e4a35af700', 'audio', 'local', NULL, NULL, 'http://api-findme.snuday.com/api/assets/media/15bbac640f394f58902fef7babe1a662.mp3', 'audio/mpeg', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, '{"semantic_meaning": ""}', '2026-05-18 23:15:13.751542+08');
COMMIT;

-- ----------------------------
-- Table structure for asset_object_detections
-- ----------------------------
DROP TABLE IF EXISTS "public"."asset_object_detections";
CREATE TABLE "public"."asset_object_detections" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "asset_id" uuid NOT NULL,
  "media_id" uuid,
  "object_name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "confidence" numeric(5,4) NOT NULL,
  "box_x" numeric(8,4) NOT NULL,
  "box_y" numeric(8,4) NOT NULL,
  "box_w" numeric(8,4) NOT NULL,
  "box_h" numeric(8,4) NOT NULL,
  "model_name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'yolo'::character varying,
  "model_version" varchar(64) COLLATE "pg_catalog"."default",
  "created_at" timestamptz(6) NOT NULL DEFAULT now()
)
;
ALTER TABLE "public"."asset_object_detections" OWNER TO "findme_user";
COMMENT ON COLUMN "public"."asset_object_detections"."id" IS '识别记录ID';
COMMENT ON COLUMN "public"."asset_object_detections"."asset_id" IS '关联资产ID';
COMMENT ON COLUMN "public"."asset_object_detections"."media_id" IS '关联媒体ID';
COMMENT ON COLUMN "public"."asset_object_detections"."object_name" IS '识别对象名称';
COMMENT ON COLUMN "public"."asset_object_detections"."confidence" IS '识别置信度';
COMMENT ON COLUMN "public"."asset_object_detections"."box_x" IS '检测框左上角X(0~1归一化)';
COMMENT ON COLUMN "public"."asset_object_detections"."box_y" IS '检测框左上角Y(0~1归一化)';
COMMENT ON COLUMN "public"."asset_object_detections"."box_w" IS '检测框宽度(0~1归一化)';
COMMENT ON COLUMN "public"."asset_object_detections"."box_h" IS '检测框高度(0~1归一化)';
COMMENT ON COLUMN "public"."asset_object_detections"."model_name" IS '识别模型名称';
COMMENT ON COLUMN "public"."asset_object_detections"."model_version" IS '识别模型版本';
COMMENT ON COLUMN "public"."asset_object_detections"."created_at" IS '创建时间';
COMMENT ON TABLE "public"."asset_object_detections" IS '资产对象识别结果表(YOLO等)';

-- ----------------------------
-- Records of asset_object_detections
-- ----------------------------
BEGIN;
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('dd3df998-f5f2-4f46-bae7-b4a39deda4a7', 'd2feaaf6-37db-4f40-b1e4-8adca5caad8b', '556b6eca-0572-41d5-b373-e3ba3a04d89f', '笔记本电脑', 0.9500, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 11:12:23.454029+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('67608239-4a94-41cf-92aa-08ee473c212c', 'd2feaaf6-37db-4f40-b1e4-8adca5caad8b', '556b6eca-0572-41d5-b373-e3ba3a04d89f', '屏幕', 0.9200, 0.3000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 11:12:23.454029+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('dc2b0aec-aed6-4e4f-aba1-cafd38cfcd65', 'd2feaaf6-37db-4f40-b1e4-8adca5caad8b', '556b6eca-0572-41d5-b373-e3ba3a04d89f', '键盘', 0.9100, 0.5000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 11:12:23.454029+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('1f6a2978-779f-445c-ac99-057e626956e3', 'd2feaaf6-37db-4f40-b1e4-8adca5caad8b', '556b6eca-0572-41d5-b373-e3ba3a04d89f', '桌面', 0.8800, 0.1000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 11:12:23.454029+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('8597c14b-ae4d-472b-ac3f-ff7c7bc504c5', 'd2feaaf6-37db-4f40-b1e4-8adca5caad8b', '556b6eca-0572-41d5-b373-e3ba3a04d89f', '线缆', 0.8500, 0.3000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 11:12:23.454029+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('76133d09-9a3b-447b-80c6-8a57caf12e94', 'f6bfbc5f-9e48-4aef-8909-90a1c4c345cd', 'ccfa140f-e9a2-4a10-a448-3c0ffc241cc5', '电源插座', 0.9500, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 11:35:31.122951+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('0d29dda5-ce75-4a5d-acc5-bca075019b25', 'f6bfbc5f-9e48-4aef-8909-90a1c4c345cd', 'ccfa140f-e9a2-4a10-a448-3c0ffc241cc5', '充电器', 0.9000, 0.3000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 11:35:31.122951+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('e344e779-e95b-4dd0-870b-bcdaece2f46d', 'f6bfbc5f-9e48-4aef-8909-90a1c4c345cd', 'ccfa140f-e9a2-4a10-a448-3c0ffc241cc5', '电线', 0.9200, 0.5000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 11:35:31.122951+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('cef72024-ef88-44ef-8202-20d62faef5ba', 'f6bfbc5f-9e48-4aef-8909-90a1c4c345cd', 'ccfa140f-e9a2-4a10-a448-3c0ffc241cc5', '杯子', 0.8500, 0.1000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 11:35:31.122951+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('5c8af4fa-5939-4887-badc-8c742e895269', '4455f679-16a5-424e-9384-4028c006b6d0', NULL, '酱油', 0.9000, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen', 'qwen-plus-latest', '2026-05-14 11:39:51.251029+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('45be4df9-2b32-4fcc-9bb7-bc504118a261', 'af0747bb-4a28-46db-ab27-9ce44402de98', NULL, '儿子', 0.9000, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen', 'qwen-plus-latest', '2026-05-14 11:44:06.855301+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('421ee449-c9fe-4b32-92db-0262d9506dc9', '768ed658-488c-4f39-a1d9-b8e2e886099d', '1eef210c-071c-47f2-b9a6-2f7fe7f63bdf', '电源插座', 0.9500, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 14:54:37.529018+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('3f754f38-8443-41b6-ba14-77368ab9e4ed', '768ed658-488c-4f39-a1d9-b8e2e886099d', '1eef210c-071c-47f2-b9a6-2f7fe7f63bdf', '充电器', 0.9000, 0.3000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 14:54:37.529018+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('82880c38-2b40-4a05-a4d6-989a035e0edd', '768ed658-488c-4f39-a1d9-b8e2e886099d', '1eef210c-071c-47f2-b9a6-2f7fe7f63bdf', '电线', 0.9200, 0.5000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 14:54:37.529018+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('4161b588-7d04-4f15-bf32-f9090bd56545', '768ed658-488c-4f39-a1d9-b8e2e886099d', '1eef210c-071c-47f2-b9a6-2f7fe7f63bdf', '杯子', 0.8500, 0.1000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 14:54:37.529018+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('46111b2a-3654-48d8-a760-5918a17fbe3b', '6ee46eae-9380-4831-b87a-f172e5042333', '94302a4a-d283-4665-873a-354659364f99', '键盘', 0.9500, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 17:20:56.162199+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('40e14019-87e0-4c20-9be2-a0cc5cebce3c', '6ee46eae-9380-4831-b87a-f172e5042333', '94302a4a-d283-4665-873a-354659364f99', '线缆', 0.8500, 0.3000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 17:20:56.162199+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('5a50e832-8305-4d8b-b0bb-30c213be862e', '6ee46eae-9380-4831-b87a-f172e5042333', '94302a4a-d283-4665-873a-354659364f99', '鼠标垫', 0.7000, 0.5000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 17:20:56.162199+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('0edd1a13-3060-43ee-bf0c-0868bd0a1b72', '6ee46eae-9380-4831-b87a-f172e5042333', '94302a4a-d283-4665-873a-354659364f99', '包装袋', 0.6000, 0.1000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-14 17:20:56.162199+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('674938b1-9402-400d-93cf-84fb7ec5c7df', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', '3a203682-7472-4d8a-9112-88750f2c549c', '建筑', 0.9500, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 17:54:49.958018+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('fdd3621e-c496-4548-82a1-7a2bcebd2123', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', '3a203682-7472-4d8a-9112-88750f2c549c', '道路', 0.9000, 0.3000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 17:54:49.958018+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('e6d25467-27dc-4653-9e0a-452c2cd8c305', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', '3a203682-7472-4d8a-9112-88750f2c549c', '树木', 0.8500, 0.5000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 17:54:49.958018+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('2c65c62e-b08b-4492-a943-97406ae8cb8b', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', '3a203682-7472-4d8a-9112-88750f2c549c', '门', 0.9000, 0.1000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 17:54:49.958018+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('c29ec915-2e4d-494e-bf0f-0322eba51fe9', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', '3a203682-7472-4d8a-9112-88750f2c549c', '台阶', 0.8500, 0.3000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 17:54:49.958018+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('ddf8a63a-c882-46c6-9180-40da01a62869', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', '3a203682-7472-4d8a-9112-88750f2c549c', '旗杆', 0.7000, 0.5000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 17:54:49.958018+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('91d66484-7710-400f-aba5-0a83b47260c6', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', '6bcabe1b-6fbd-4760-a15c-d606e623ef9c', '风扇', 0.9500, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:39:17.52572+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('c88d76d4-40c7-44d9-ae6d-b2b885c1228e', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', '6bcabe1b-6fbd-4760-a15c-d606e623ef9c', '桌子', 0.8500, 0.3000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:39:17.52572+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('1f772b45-e8fb-44b0-8de7-0de502686bef', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', '6bcabe1b-6fbd-4760-a15c-d606e623ef9c', '衣物', 0.8000, 0.5000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:39:17.52572+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('55a5571d-9b59-4b9c-a5ca-0364e5320337', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', '6bcabe1b-6fbd-4760-a15c-d606e623ef9c', '储物架', 0.7500, 0.1000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:39:17.52572+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('0ebd9af2-6fb8-4457-a190-4b402cb1c882', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', '6bcabe1b-6fbd-4760-a15c-d606e623ef9c', '玩具', 0.7000, 0.3000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:39:17.52572+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('a63757bb-c7ff-48be-981e-cfbef8a7a407', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', '6bcabe1b-6fbd-4760-a15c-d606e623ef9c', '吸尘器', 0.6500, 0.5000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:39:17.52572+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('05a7d79f-5f27-4155-82cd-5926f87ec462', '8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', '95f433c7-c4db-4ca7-bacd-5fc8509245b1', '镜子', 0.9500, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('7b59489e-7f4c-45b8-9a3e-62f0bd6c322c', '8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', '95f433c7-c4db-4ca7-bacd-5fc8509245b1', '手', 0.9000, 0.3000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('971ba0bf-4bc2-43b3-82f3-983c31adef8b', '8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', '95f433c7-c4db-4ca7-bacd-5fc8509245b1', '腹部', 0.8500, 0.5000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('5e10dd8f-b6f6-401c-9f75-e952a2b79911', '8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', '95f433c7-c4db-4ca7-bacd-5fc8509245b1', '窗户', 0.9000, 0.1000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('f4e28c40-f3db-4184-be7f-b30c96389b06', '8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', '95f433c7-c4db-4ca7-bacd-5fc8509245b1', '盒子', 0.8000, 0.3000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('7758e15d-be2a-409d-a591-6691f28f35a7', '8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', '95f433c7-c4db-4ca7-bacd-5fc8509245b1', '梳子', 0.7000, 0.5000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('bf84ed78-a54e-47c2-86be-0bee0159d6db', '38f80a88-b75a-4d03-bab3-2d34237c4aa3', '849ab8e9-fa89-48e6-892a-947e9a8d2e0c', '笔记本电脑', 0.9500, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:49:44.999978+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('40b6472d-ab7b-4de0-bb97-891536c57c92', '38f80a88-b75a-4d03-bab3-2d34237c4aa3', '849ab8e9-fa89-48e6-892a-947e9a8d2e0c', '水瓶', 0.9000, 0.3000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:49:44.999978+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('27c593ca-8be6-49dd-8ffe-69fb188f0bf4', '38f80a88-b75a-4d03-bab3-2d34237c4aa3', '849ab8e9-fa89-48e6-892a-947e9a8d2e0c', '线缆', 0.8500, 0.5000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:49:44.999978+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('79083fa6-43dd-430c-9d48-84b684da3115', '1fae6a5f-f2b9-4a84-ab96-e74668151273', 'b954b94f-bcf5-4c62-aa6c-c90b5a8d7d43', '袜子', 0.9500, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:56:17.914977+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('baac22eb-85c4-4294-ae09-5d5e2b8fc406', '1fae6a5f-f2b9-4a84-ab96-e74668151273', 'b954b94f-bcf5-4c62-aa6c-c90b5a8d7d43', '床', 0.9000, 0.3000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:56:17.914977+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('4895d3d5-27b6-4e55-b1a2-6301ae252ec4', '1fae6a5f-f2b9-4a84-ab96-e74668151273', 'b954b94f-bcf5-4c62-aa6c-c90b5a8d7d43', '储物架', 0.8500, 0.5000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:56:17.914977+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('1d73da81-7c4b-4bfc-8e9e-e70cccec227b', '1fae6a5f-f2b9-4a84-ab96-e74668151273', 'b954b94f-bcf5-4c62-aa6c-c90b5a8d7d43', '风扇', 0.8000, 0.1000, 0.3000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-15 18:56:17.914977+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('c2bf9dbc-41ff-45bb-9a9a-b1c9c2ce2a61', '5c8b71c1-037f-4d3e-9b99-080fcfcc7456', 'ba8a3dae-d6eb-499e-93bc-7924ed5c18f1', '备忘录', 0.9000, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-17 07:22:36.076085+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('6f25a94e-bcca-46f9-bc80-a0d5b1062edd', 'f73fc527-22bc-4f6e-9ca8-a24c741c994a', '1eb51a9e-5cb4-4f98-a73e-63ddf84e18fa', '手机', 0.9500, 0.1000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-17 07:23:39.062111+08');
INSERT INTO "public"."asset_object_detections" ("id", "asset_id", "media_id", "object_name", "confidence", "box_x", "box_y", "box_w", "box_h", "model_name", "model_version", "created_at") VALUES ('683a8dad-4f61-4199-8c30-4b241832f349', 'f73fc527-22bc-4f6e-9ca8-a24c741c994a', '1eb51a9e-5cb4-4f98-a73e-63ddf84e18fa', '数据线', 0.9000, 0.3000, 0.1000, 0.2000, 0.2000, 'qwen-vl', 'qwen-vl-plus', '2026-05-17 07:23:39.062111+08');
COMMIT;

-- ----------------------------
-- Table structure for asset_tags
-- ----------------------------
DROP TABLE IF EXISTS "public"."asset_tags";
CREATE TABLE "public"."asset_tags" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "asset_id" uuid NOT NULL,
  "tag_id" uuid NOT NULL,
  "source" "public"."tag_source_enum" NOT NULL DEFAULT 'ai'::tag_source_enum,
  "confidence" numeric(5,4),
  "created_at" timestamptz(6) NOT NULL DEFAULT now()
)
;
ALTER TABLE "public"."asset_tags" OWNER TO "findme_user";
COMMENT ON COLUMN "public"."asset_tags"."id" IS '关联记录ID';
COMMENT ON COLUMN "public"."asset_tags"."asset_id" IS '资产ID';
COMMENT ON COLUMN "public"."asset_tags"."tag_id" IS '标签ID';
COMMENT ON COLUMN "public"."asset_tags"."source" IS '标签来源(ai/manual/system)';
COMMENT ON COLUMN "public"."asset_tags"."confidence" IS '标签置信度';
COMMENT ON COLUMN "public"."asset_tags"."created_at" IS '创建时间';
COMMENT ON TABLE "public"."asset_tags" IS '资产-标签关联表';

-- ----------------------------
-- Records of asset_tags
-- ----------------------------
BEGIN;
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('957da15a-9a0f-4350-8dcf-673c3a55ab4f', 'd2feaaf6-37db-4f40-b1e4-8adca5caad8b', '75567835-0797-46ff-b8a4-66b81fc6645c', 'ai', 0.9000, '2026-05-14 11:12:23.454029+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('38473837-5409-4a63-8cc3-13b3d800f3cc', 'd2feaaf6-37db-4f40-b1e4-8adca5caad8b', 'e7db3ea2-9b6c-4cc7-9db9-4c18930c461e', 'ai', 0.9000, '2026-05-14 11:12:23.454029+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('b03b6776-3e0a-49da-a449-ba726decc143', 'f6bfbc5f-9e48-4aef-8909-90a1c4c345cd', '7af3cc56-9f37-4de1-afce-a6596b770e17', 'ai', 0.9000, '2026-05-14 11:35:31.122951+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('73397dde-d5de-42bc-b882-a7ddc39691d0', 'f6bfbc5f-9e48-4aef-8909-90a1c4c345cd', '75567835-0797-46ff-b8a4-66b81fc6645c', 'ai', 0.9000, '2026-05-14 11:35:31.122951+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('42208c73-1856-4b92-a04b-8769ca129e96', '4455f679-16a5-424e-9384-4028c006b6d0', 'be21ab16-e6d5-460c-a32b-44b025b68040', 'ai', 0.9000, '2026-05-14 11:39:51.251029+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('a623589d-ab62-45fb-a844-45885f6ce6b8', '4455f679-16a5-424e-9384-4028c006b6d0', 'a66d3ae8-a49e-44c9-989d-fff33255f1d3', 'ai', 0.9000, '2026-05-14 11:39:51.251029+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('116fb1bc-60a1-450f-bf12-ecdcf5598a75', '4455f679-16a5-424e-9384-4028c006b6d0', '43d4d39d-1e12-4708-88d2-42ed054656d5', 'ai', 0.9000, '2026-05-14 11:39:51.251029+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('b27cd0ea-5cc2-4f5c-beff-cd8b2792478a', 'af0747bb-4a28-46db-ab27-9ce44402de98', '5d9f8372-a8d6-4b8c-8982-26d6f98961a5', 'ai', 0.9000, '2026-05-14 11:44:06.855301+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('f6303331-3f98-4e32-9844-837d668b1fcf', 'af0747bb-4a28-46db-ab27-9ce44402de98', 'ffeda077-33fd-4d4a-b31d-1ef7c39bdfde', 'ai', 0.9000, '2026-05-14 11:44:06.855301+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('63a90682-4977-4cf6-996e-24c13999b24e', 'af0747bb-4a28-46db-ab27-9ce44402de98', '171875ba-c94d-45cc-b327-94a7200d436a', 'ai', 0.9000, '2026-05-14 11:44:06.855301+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('ca6f50e7-b00d-4921-b7bf-2526c77593b2', '768ed658-488c-4f39-a1d9-b8e2e886099d', '7af3cc56-9f37-4de1-afce-a6596b770e17', 'ai', 0.9000, '2026-05-14 14:54:37.529018+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('1ca7fd09-b441-4a84-9449-a2ae99964af9', '768ed658-488c-4f39-a1d9-b8e2e886099d', '75567835-0797-46ff-b8a4-66b81fc6645c', 'ai', 0.9000, '2026-05-14 14:54:37.529018+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('a9d6e41e-c820-4d72-b5c1-4b36e3d1fad2', '6ee46eae-9380-4831-b87a-f172e5042333', '7af3cc56-9f37-4de1-afce-a6596b770e17', 'ai', 0.9000, '2026-05-14 17:20:56.162199+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('5fd40f2b-dee1-4526-88da-78a89801a9d7', '6ee46eae-9380-4831-b87a-f172e5042333', '75567835-0797-46ff-b8a4-66b81fc6645c', 'ai', 0.9000, '2026-05-14 17:20:56.162199+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('03444426-82d5-4ae5-aee9-9051e419bcdb', '6ee46eae-9380-4831-b87a-f172e5042333', 'b30c9314-ad46-486b-b92d-764aef204aa4', 'ai', 0.9000, '2026-05-14 17:20:56.162199+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('8ac58f85-0cfa-439d-9f93-43319c2397c1', '3c4bc399-9065-4cc9-b969-f12fc8e7c49f', '68501304-9dae-4b05-a779-d7f43483120f', 'ai', 0.9000, '2026-05-14 21:39:19.544298+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('1cb27350-d38c-4c45-91ba-6570ee2d14ee', '3c4bc399-9065-4cc9-b969-f12fc8e7c49f', '008e468e-3734-4a5d-ac73-215e9a695c4f', 'ai', 0.9000, '2026-05-14 21:39:19.544298+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('7f1cbd5b-3d8c-4d92-bbbb-a2ebce40a350', '05634726-abdd-40c3-9a32-2ef3db023f37', '68501304-9dae-4b05-a779-d7f43483120f', 'ai', 0.9000, '2026-05-15 08:43:51.039155+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('3f08200a-31bc-470f-a0e2-a3a1c68516a3', '05634726-abdd-40c3-9a32-2ef3db023f37', '008e468e-3734-4a5d-ac73-215e9a695c4f', 'ai', 0.9000, '2026-05-15 08:43:51.039155+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('a2a3b059-e784-4048-9231-e50699c5fb51', '9b0ced64-e56a-4e1b-9f84-fed6822a7b41', 'de10d8e7-c14f-48d3-9b75-af213ec3a70d', 'ai', 0.9000, '2026-05-15 08:46:14.114465+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('b98b56c0-82c4-4955-8382-eba6e2539904', '9b0ced64-e56a-4e1b-9f84-fed6822a7b41', 'dc1dfc55-ec06-4be7-b04d-fff4bdb5f4ca', 'ai', 0.9000, '2026-05-15 08:46:14.114465+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('357ec843-5b06-40e7-8676-395913cead09', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', '7af3cc56-9f37-4de1-afce-a6596b770e17', 'ai', 0.9000, '2026-05-15 17:54:49.958018+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('3c5e1b32-2029-4280-b184-c0ecf5873310', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', '6bc34c8c-d639-415b-9e96-edbed1460204', 'ai', 0.9000, '2026-05-15 17:54:49.958018+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('a61bed07-0b97-4d1a-a8a3-c7f724eb4e12', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', '4f52efc4-ac87-4546-bb8d-19781ef12273', 'ai', 0.9000, '2026-05-15 17:54:49.958018+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('dd1b7472-4baf-41c6-aa5d-8f8217108edb', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', '7af3cc56-9f37-4de1-afce-a6596b770e17', 'ai', 0.9000, '2026-05-15 18:39:17.52572+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('9800e0ad-b784-4f7b-89c1-a2dd86913793', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', '49d2ddf6-f05f-49c3-a940-11b32881c358', 'ai', 0.9000, '2026-05-15 18:39:17.52572+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('425a1df5-7d9a-4baa-a72f-41e33dfec717', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', 'c6ed4375-4fc5-4c1c-9091-dd1d1c6759f0', 'ai', 0.9000, '2026-05-15 18:39:17.52572+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('cf752184-eb91-4953-97cb-8f257f1b6174', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', 'e960f86a-6b6b-4041-829c-42a310f7b4a4', 'ai', 0.9000, '2026-05-15 18:39:17.52572+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('257d85cb-c0e2-4677-997d-b91fc4040507', '8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', '7af3cc56-9f37-4de1-afce-a6596b770e17', 'ai', 0.9000, '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('bf78b3a7-d96d-4372-a6b3-a56bc22d4c6c', '8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', '49d2ddf6-f05f-49c3-a940-11b32881c358', 'ai', 0.9000, '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('7095b50b-a1e6-4af2-8622-627533788b68', '8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', 'c2417ad5-4aa3-4d67-9e06-40b19ab1b81c', 'ai', 0.9000, '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('597bd1b3-41f5-4893-9b0d-5fea95c9fb1c', '8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', 'ce1af322-958a-475d-8e6f-760fe4a25c50', 'ai', 0.9000, '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('bf4f837f-b6e2-448f-9691-694b06b8c962', '601e35a9-1a59-4394-ac78-c83c048f89e3', '68501304-9dae-4b05-a779-d7f43483120f', 'ai', 0.9000, '2026-05-15 18:45:23.543196+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('d502843b-63f1-476f-b4f8-68149a4a1c4b', '601e35a9-1a59-4394-ac78-c83c048f89e3', '008e468e-3734-4a5d-ac73-215e9a695c4f', 'ai', 0.9000, '2026-05-15 18:45:23.543196+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('14b8db20-2f6e-47aa-94fe-60bed59c297d', 'ebf7e3b6-8d81-4407-8840-935251683bd2', '68501304-9dae-4b05-a779-d7f43483120f', 'ai', 0.9000, '2026-05-15 18:47:02.804136+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('6cf5345b-be9b-42b9-bf80-033b5d14e5f4', 'ebf7e3b6-8d81-4407-8840-935251683bd2', '008e468e-3734-4a5d-ac73-215e9a695c4f', 'ai', 0.9000, '2026-05-15 18:47:02.804136+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('015566c8-2643-4c17-a5ba-3c9fd57642e5', '38f80a88-b75a-4d03-bab3-2d34237c4aa3', '75567835-0797-46ff-b8a4-66b81fc6645c', 'ai', 0.9000, '2026-05-15 18:49:44.999978+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('31e95da7-8166-4f69-8a9c-fd789ce5db5a', '1fae6a5f-f2b9-4a84-ab96-e74668151273', '7af3cc56-9f37-4de1-afce-a6596b770e17', 'ai', 0.9000, '2026-05-15 18:56:17.914977+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('b5e7c507-ec0f-4fb9-9551-df400328a37d', '1fae6a5f-f2b9-4a84-ab96-e74668151273', 'c4769c3f-a0ef-4e4f-b614-69fdc8f942f0', 'ai', 0.9000, '2026-05-15 18:56:17.914977+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('d4bec614-103c-4204-b05d-89f8ca4942a0', '1fae6a5f-f2b9-4a84-ab96-e74668151273', 'c6ed4375-4fc5-4c1c-9091-dd1d1c6759f0', 'ai', 0.9000, '2026-05-15 18:56:17.914977+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('3dd5450a-5a1f-4d8b-aa90-73c5331cf2fd', 'c1754a01-2fba-4d66-a058-4cf74620601f', '68501304-9dae-4b05-a779-d7f43483120f', 'ai', 0.9000, '2026-05-15 19:06:11.062644+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('12779385-93c7-4a16-9dc1-357bf473990b', 'c1754a01-2fba-4d66-a058-4cf74620601f', '008e468e-3734-4a5d-ac73-215e9a695c4f', 'ai', 0.9000, '2026-05-15 19:06:11.062644+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('feb9f0fc-dc68-43d4-b65d-40c585d99c3b', '5c8b71c1-037f-4d3e-9b99-080fcfcc7456', '7af3cc56-9f37-4de1-afce-a6596b770e17', 'ai', 0.9000, '2026-05-17 07:22:36.076085+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('4359a988-29fe-401d-95bf-72db94c9e022', 'f73fc527-22bc-4f6e-9ca8-a24c741c994a', '7af3cc56-9f37-4de1-afce-a6596b770e17', 'ai', 0.9000, '2026-05-17 07:23:39.062111+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('6212feaa-260f-48bc-bba5-de7ea98a1eb2', 'f73fc527-22bc-4f6e-9ca8-a24c741c994a', '75567835-0797-46ff-b8a4-66b81fc6645c', 'ai', 0.9000, '2026-05-17 07:23:39.062111+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('97751b83-ce48-45a9-b3b7-9fe2fa69db06', 'fabe52c3-75ca-49fb-9352-d2c55900e1b0', '68501304-9dae-4b05-a779-d7f43483120f', 'ai', 0.9000, '2026-05-18 21:26:57.329927+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('9e1ced12-6a7a-4586-8615-1f5b9616a278', 'fabe52c3-75ca-49fb-9352-d2c55900e1b0', '008e468e-3734-4a5d-ac73-215e9a695c4f', 'ai', 0.9000, '2026-05-18 21:26:57.329927+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('34eb8d0d-c4d4-4895-aa9c-98d5af5e03a5', '38f80a88-b75a-4d03-bab3-2d34237c4aa3', '4889f056-7f63-41a4-ab83-106b6c6dbc7b', 'ai', 0.8500, '2026-05-18 21:57:58.636669+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('4d03982d-0a09-43a6-b3f2-4773a3f75ed6', '38f80a88-b75a-4d03-bab3-2d34237c4aa3', '4ddf1594-d0aa-4f23-8a33-50fb9e3049ca', 'ai', 0.8500, '2026-05-18 21:57:58.636669+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('5a35af9a-0024-48fd-9f29-621f305bd9c9', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', 'ee53a7d5-4646-4d05-b86d-8019f4dd02a3', 'ai', 0.8500, '2026-05-18 21:58:10.391498+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('f387f3ab-e20c-4a29-8a03-1de6f58986b6', '7d8538e8-779d-4db2-afe5-c8a6f421eb82', 'c914f975-e1f6-4f71-9ec7-0419448bd6b4', 'ai', 0.8500, '2026-05-18 21:58:10.391498+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('03f0d491-804b-458f-b0f1-49499ec5ba59', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', '6bf68d85-ca2d-48ae-9a11-d731b8e4e4c0', 'ai', 0.8500, '2026-05-18 21:58:16.095612+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('18958bb0-45f6-4a95-bdb9-d89cc958f951', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', 'a64c2bc4-1b14-4330-9cf4-e7b4647c3c3b', 'ai', 0.8500, '2026-05-18 21:58:16.095612+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('74d9da0b-5e1b-4806-b8fe-8aa3d1714767', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', '51262a2f-b8bc-4b9e-8da4-f82536521d75', 'ai', 0.8500, '2026-05-18 21:58:16.095612+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('5f78db35-1d8f-4cbc-8ad0-a2430bd5cfda', 'eeffc358-3c6d-434f-9b9c-1b1024e7b103', 'b1ba7601-9541-4809-81bb-a80ddd735293', 'ai', 0.8500, '2026-05-18 21:58:16.095612+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('69c29e2d-5304-43f5-8284-af4f141ce4cf', 'f73fc527-22bc-4f6e-9ca8-a24c741c994a', '80d1bea1-6e0a-48d3-b49a-c8bb85d72575', 'ai', 0.8500, '2026-05-18 21:58:22.863621+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('eebe5f1d-92f0-4771-9e1b-1e11b3a76a9f', 'f73fc527-22bc-4f6e-9ca8-a24c741c994a', '0734fb0e-8e59-4811-979e-0ceb9539d9cf', 'ai', 0.8500, '2026-05-18 21:58:22.863621+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('fbc74f8e-ad93-4f04-aac2-d54f42b6c0d7', 'f73fc527-22bc-4f6e-9ca8-a24c741c994a', '4889f056-7f63-41a4-ab83-106b6c6dbc7b', 'ai', 0.8500, '2026-05-18 21:58:22.863621+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('72ad14c1-bbf4-4ee9-abdc-8fea6f9b84e5', 'fabe52c3-75ca-49fb-9352-d2c55900e1b0', '15540471-b486-4014-be42-06d180eceecf', 'ai', 0.8500, '2026-05-18 21:58:54.677196+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('eef12b92-8764-4391-b7dd-e0b008e91c16', 'fabe52c3-75ca-49fb-9352-d2c55900e1b0', '247f3a29-0474-422a-880f-288ca694f77d', 'ai', 0.8500, '2026-05-18 21:58:54.677196+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('9095b6ad-a6c1-4136-90a5-9dcd24f02b48', 'c1754a01-2fba-4d66-a058-4cf74620601f', '15540471-b486-4014-be42-06d180eceecf', 'ai', 0.8500, '2026-05-18 21:59:01.791106+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('406ccea4-5564-444b-9ffc-28d0c520cef7', 'c1754a01-2fba-4d66-a058-4cf74620601f', '247f3a29-0474-422a-880f-288ca694f77d', 'ai', 0.8500, '2026-05-18 21:59:01.791106+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('692ddfcb-fb01-42ac-9476-c21be88acba9', '70132d31-bc8c-47f2-929e-1f99bd432fe6', '68501304-9dae-4b05-a779-d7f43483120f', 'ai', 0.9000, '2026-05-18 23:09:58.967483+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('90dbcb92-3dc4-4c80-b4c2-98b7d5fc45eb', '70132d31-bc8c-47f2-929e-1f99bd432fe6', '008e468e-3734-4a5d-ac73-215e9a695c4f', 'ai', 0.9000, '2026-05-18 23:09:58.967483+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('ddcb397b-830c-4249-a2f5-2f131739520f', 'a9092dc5-3960-4cae-bec2-6d1f27765691', '68501304-9dae-4b05-a779-d7f43483120f', 'ai', 0.9000, '2026-05-18 23:11:36.865439+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('a0585d01-b1e6-4f56-86fe-f49480c852ee', 'a9092dc5-3960-4cae-bec2-6d1f27765691', '008e468e-3734-4a5d-ac73-215e9a695c4f', 'ai', 0.9000, '2026-05-18 23:11:36.865439+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('c43daf47-ad63-4f0d-b2c1-3643d3e48d7d', '1433e0db-3fd1-49f5-94ac-25e4a35af700', '68501304-9dae-4b05-a779-d7f43483120f', 'ai', 0.9000, '2026-05-18 23:15:13.751542+08');
INSERT INTO "public"."asset_tags" ("id", "asset_id", "tag_id", "source", "confidence", "created_at") VALUES ('c0ddea8b-4efd-43cd-bd56-e3c18b6f6afc', '1433e0db-3fd1-49f5-94ac-25e4a35af700', '008e468e-3734-4a5d-ac73-215e9a695c4f', 'ai', 0.9000, '2026-05-18 23:15:13.751542+08');
COMMIT;

-- ----------------------------
-- Table structure for assets
-- ----------------------------
DROP TABLE IF EXISTS "public"."assets";
CREATE TABLE "public"."assets" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "asset_type" "public"."asset_type_enum" NOT NULL,
  "status" "public"."asset_status_enum" NOT NULL DEFAULT 'active'::asset_status_enum,
  "source_modality" "public"."modality_enum" NOT NULL DEFAULT 'text'::modality_enum,
  "title" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
  "summary" text COLLATE "pg_catalog"."default",
  "content_text" text COLLATE "pg_catalog"."default",
  "event_time_start" timestamptz(6),
  "event_time_end" timestamptz(6),
  "captured_at" timestamptz(6) NOT NULL DEFAULT now(),
  "location_name" varchar(200) COLLATE "pg_catalog"."default",
  "address" text COLLATE "pg_catalog"."default",
  "latitude" numeric(10,7),
  "longitude" numeric(10,7),
  "classify_confidence" numeric(5,4),
  "metadata" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "created_at" timestamptz(6) NOT NULL DEFAULT now(),
  "updated_at" timestamptz(6) NOT NULL DEFAULT now(),
  "deleted_at" timestamptz(6)
)
;
ALTER TABLE "public"."assets" OWNER TO "findme_user";
COMMENT ON COLUMN "public"."assets"."id" IS '资产ID';
COMMENT ON COLUMN "public"."assets"."user_id" IS '所属用户ID';
COMMENT ON COLUMN "public"."assets"."asset_type" IS '资产类型(item/event)';
COMMENT ON COLUMN "public"."assets"."status" IS '资产状态';
COMMENT ON COLUMN "public"."assets"."source_modality" IS '主要录入模态';
COMMENT ON COLUMN "public"."assets"."title" IS '资产标题';
COMMENT ON COLUMN "public"."assets"."summary" IS '摘要文本';
COMMENT ON COLUMN "public"."assets"."content_text" IS '正文文本(ASR/OCR/手输聚合)';
COMMENT ON COLUMN "public"."assets"."event_time_start" IS '事件开始时间';
COMMENT ON COLUMN "public"."assets"."event_time_end" IS '事件结束时间';
COMMENT ON COLUMN "public"."assets"."captured_at" IS '采集时间';
COMMENT ON COLUMN "public"."assets"."location_name" IS '位置名称';
COMMENT ON COLUMN "public"."assets"."address" IS '详细地址';
COMMENT ON COLUMN "public"."assets"."latitude" IS '纬度';
COMMENT ON COLUMN "public"."assets"."longitude" IS '经度';
COMMENT ON COLUMN "public"."assets"."classify_confidence" IS '自动分类置信度';
COMMENT ON COLUMN "public"."assets"."metadata" IS '扩展元数据(JSON)';
COMMENT ON COLUMN "public"."assets"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."assets"."updated_at" IS '更新时间';
COMMENT ON COLUMN "public"."assets"."deleted_at" IS '软删除时间';
COMMENT ON TABLE "public"."assets" IS '记忆资产主表(物品/事件统一模型)';

-- ----------------------------
-- Records of assets
-- ----------------------------
BEGIN;
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('f6bfbc5f-9e48-4aef-8909-90a1c4c345cd', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'active', 'photo', '办公桌充电区', '电源插座旁有充电器、电线和杯子', NULL, NULL, NULL, '2026-05-14 11:35:35.482268+08', NULL, NULL, NULL, NULL, 0.9200, '{"mode": "image", "scene": "办公桌上的电源插座和充电设备", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "image_url": "http://api-findme.snuday.com/api/assets/media/b46470e9e3714a3392b06e9ce1122c69.jpg", "cover_title": "办公桌充电区，2026-05-14"}', '2026-05-14 11:35:31.122951+08', '2026-05-14 11:35:31.122951+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('af0747bb-4a28-46db-ab27-9ce44402de98', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'event', 'active', 'text', '儿子体检', '今天下午三点带儿子做体检', '今天把儿子的体检要做了，大概下午三点', NULL, NULL, '2026-05-14 11:44:09.505283+08', NULL, NULL, NULL, NULL, 0.9200, '{"mode": "text", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "cover_title": "儿子体检，2026-05-14"}', '2026-05-14 11:44:06.855301+08', '2026-05-14 11:44:06.855301+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('768ed658-488c-4f39-a1d9-b8e2e886099d', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'active', 'photo', '办公桌充电区', '电源插座旁有充电器、电线和杯子', NULL, NULL, NULL, '2026-05-14 14:54:41.754457+08', NULL, NULL, NULL, NULL, 0.9200, '{"mode": "image", "scene": "办公桌上的电源插座和充电设备", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "image_url": "http://api-findme.snuday.com/api/assets/media/b3da6fd1431f49d0b9a60a34ec9b680e.jpg", "cover_title": "办公桌充电区，2026-05-14"}', '2026-05-14 14:54:37.529018+08', '2026-05-14 14:54:37.529018+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('d2feaaf6-37db-4f40-b1e4-8adca5caad8b', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'active', 'photo', '图片备忘录', '一台笔记本电脑在办公桌上运行代码。', NULL, NULL, NULL, '2026-05-14 11:12:27.126012+08', NULL, NULL, NULL, NULL, 0.9200, '{"mode": "image", "scene": "一台笔记本电脑在办公桌上运行代码。", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "image_url": "http://api-findme.snuday.com/api/assets/media/b3c1146f8b9b4c518d1d306a857534b7.jpg", "cover_title": "图片备忘录，2026-05-14"}', '2026-05-14 11:12:23.454029+08', '2026-05-14 16:15:57.760072+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('4455f679-16a5-424e-9384-4028c006b6d0', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'deleted', 'text', '酱油购入两瓶', '今天买了两瓶酱油，可用至7月', '我今天把酱油买了两瓶，可以用到7月份', NULL, NULL, '2026-05-14 11:39:54.236212+08', NULL, NULL, NULL, NULL, 0.9200, '{"mode": "text", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "cover_title": "酱油购入两瓶，2026-05-14"}', '2026-05-14 11:39:51.251029+08', '2026-05-14 16:52:07.288375+08', '2026-05-14 16:52:07.288375+08');
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('6ee46eae-9380-4831-b87a-f172e5042333', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'active', 'photo', '办公桌键盘特写', '黑色键盘配杂乱线缆与杂物', NULL, NULL, NULL, '2026-05-14 17:21:01.889329+08', '定位(39.2165, 117.2693)', NULL, 39.2164855, 117.2692582, 0.9200, '{"mode": "image", "scene": "一张办公桌上的黑色键盘特写，周围有线缆和杂物。", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "image_url": "http://api-findme.snuday.com/api/assets/media/5f37df6a131c44fcac8e8dc678bf81f1.jpg", "cover_title": "办公桌键盘特写，2026-05-14"}', '2026-05-14 17:20:56.162199+08', '2026-05-14 17:20:56.162199+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('05634726-abdd-40c3-9a32-2ef3db023f37', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'event', 'active', 'voice', '语音备忘录', '语音记录的简要备忘', NULL, NULL, NULL, '2026-05-15 08:43:55.905757+08', NULL, NULL, NULL, NULL, 0.9200, '{"mode": "voice", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "audio_url": "http://tmp/J3dTSZ72QU764896a479e94a68ad114017cac2bc3415.durationTime=18761.mp3", "cover_title": "语音备忘录，2026-05-15"}', '2026-05-15 08:43:51.039155+08', '2026-05-15 08:43:51.039155+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('eeffc358-3c6d-434f-9b9c-1b1024e7b103', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'active', 'photo', '现代建筑外景', '现代风格建筑旁有道路树木和门', NULL, NULL, NULL, '2026-05-15 17:54:54.817886+08', NULL, NULL, NULL, NULL, 0.9200, '{"mode": "image", "scene": "一栋现代风格的建筑外部，旁边有道路和树木。", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "image_url": "http://api-findme.snuday.com/api/assets/media/3ef5b2dc089f4a0ab69b3302b26e10ba.jpg", "cover_title": "现代建筑外景，2026-05-15"}', '2026-05-15 17:54:49.958018+08', '2026-05-15 17:54:49.958018+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('7d8538e8-779d-4db2-afe5-c8a6f421eb82', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'active', 'photo', '杂乱室内一角', '风扇、桌子、衣物和储物架共存的室内场景', NULL, NULL, NULL, '2026-05-15 18:39:23.41496+08', NULL, NULL, NULL, NULL, 0.9200, '{"mode": "image", "scene": "室内房间，摆放着风扇、桌子和杂物。", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "image_url": "http://api-findme.snuday.com/api/assets/media/9d8c88ed96b740c39242bdf4163c049f.jpg", "cover_title": "杂乱室内一角，2026-05-15"}', '2026-05-15 18:39:17.52572+08', '2026-05-15 18:39:17.52572+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('601e35a9-1a59-4394-ac78-c83c048f89e3', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'event', 'active', 'voice', '语音备忘录', '语音记录的简要备忘', NULL, NULL, NULL, '2026-05-15 18:45:26.26503+08', NULL, NULL, NULL, NULL, 0.9200, '{"mode": "voice", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "audio_url": "http://api-findme.snuday.com/api/assets/media/4747c028252742cfa3a58c9c3fc9e366.mp3", "cover_title": "语音备忘录，2026-05-15"}', '2026-05-15 18:45:23.543196+08', '2026-05-15 18:45:23.543196+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('ebf7e3b6-8d81-4407-8840-935251683bd2', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'event', 'active', 'voice', '语音备忘录', '语音记录的简要备忘', NULL, NULL, NULL, '2026-05-15 18:47:05.141353+08', '定位(39.1688, 117.2917)', NULL, 39.1687505, 117.2916993, 0.9200, '{"mode": "voice", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "audio_url": "http://api-findme.snuday.com/api/assets/media/a4325dd0a7f24d58990ca2abcede48d5.mp3", "cover_title": "语音备忘录，2026-05-15"}', '2026-05-15 18:47:02.804136+08', '2026-05-15 18:47:02.804136+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('38f80a88-b75a-4d03-bab3-2d34237c4aa3', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'active', 'mixed', '桌面工作场景', '笔记本电脑、水瓶和线缆在桌面上', NULL, NULL, NULL, '2026-05-15 18:49:53.309008+08', '定位(39.1688, 117.2917)', NULL, 39.1687505, 117.2916993, 0.9200, '{"mode": "video", "scene": "一张桌子上放着笔记本电脑、一瓶水和一根线缆。", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "image_url": "http://api-findme.snuday.com/api/assets/media/30215b188c314dad949c8f7dfbff3a73.jpg", "video_url": "http://api-findme.snuday.com/api/assets/media/c080ebe2ec334fedb8c418d7cf6e399e.mp4", "cover_title": "桌面工作场景，2026-05-15"}', '2026-05-15 18:49:44.999978+08', '2026-05-15 18:49:44.999978+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('c1754a01-2fba-4d66-a058-4cf74620601f', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'event', 'active', 'voice', '语音备忘录', '语音记录的简要备忘', NULL, NULL, NULL, '2026-05-15 19:06:13.546262+08', '定位(39.1396, 117.2932)', NULL, 39.1396476, 117.2931656, 0.9200, '{"mode": "voice", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "audio_url": "http://api-findme.snuday.com/api/assets/media/d3343fba9a0d4f4e88d8a51457aad74f.mp3", "cover_title": "语音备忘录，2026-05-15"}', '2026-05-15 19:06:11.062644+08', '2026-05-15 19:06:11.062644+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('9b0ced64-e56a-4e1b-9f84-fed6822a7b41', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'deleted', 'mixed', '视频备忘录', '记录重要视频内容', NULL, NULL, NULL, '2026-05-15 08:46:16.602128+08', NULL, NULL, NULL, NULL, 0.9200, '{"mode": "video", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "video_url": "http://tmp/uMhMHTQDRsqpdafde5f3980f56163a7d4db033e45b97.webm", "cover_title": "视频备忘录，2026-05-15"}', '2026-05-15 08:46:14.114465+08', '2026-05-15 19:54:44.141291+08', '2026-05-15 19:54:44.141291+08');
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('3c4bc399-9065-4cc9-b969-f12fc8e7c49f', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'deleted', 'voice', '语音备忘录', '语音记录的简要备忘', NULL, NULL, NULL, '2026-05-14 21:39:22.235661+08', '定位(39.1751, 117.2901)', NULL, 39.1751088, 117.2901223, 0.9200, '{"mode": "voice", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "audio_url": "http://api-findme.snuday.com/api/assets/media/39e5893f85ff44ffac24113ff0d96dc2.mp3", "cover_title": "语音备忘录，2026-05-14"}', '2026-05-14 21:39:19.544298+08', '2026-05-15 19:54:53.279677+08', '2026-05-15 19:54:53.279677+08');
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('8e6cc0df-1cb0-4a63-888e-5fed97a1ad31', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'deleted', 'photo', '窗边照腹', '人在窗边用镜子照腹部', NULL, NULL, NULL, '2026-05-15 18:40:14.100734+08', NULL, NULL, NULL, NULL, 0.9200, '{"mode": "image", "scene": "一个人在窗边用镜子照自己的腹部。", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "image_url": "http://api-findme.snuday.com/api/assets/media/1d61b8f7cebf400ca7405f590f77c7ae.jpg", "cover_title": "窗边照腹，2026-05-15"}', '2026-05-15 18:40:07.847493+08', '2026-05-17 07:09:23.103184+08', '2026-05-17 07:09:23.103184+08');
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('1fae6a5f-f2b9-4a84-ab96-e74668151273', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'deleted', 'photo', '床上袜子与储物架', '床上几双袜子，背景是储物架和风扇。', NULL, NULL, NULL, '2026-05-15 18:56:23.219445+08', '定位(39.1687, 117.2564)', NULL, 39.1687242, 117.2564433, 0.9200, '{"mode": "image", "scene": "床上放着几双袜子，背景是储物架和风扇。", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "image_url": "http://api-findme.snuday.com/api/assets/media/44308d5a61bf45c2a2d411ce6180d9bb.jpg", "cover_title": "床上袜子与储物架，2026-05-15"}', '2026-05-15 18:56:17.914977+08', '2026-05-15 19:54:37.934105+08', '2026-05-15 19:54:37.934105+08');
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('5c8b71c1-037f-4d3e-9b99-080fcfcc7456', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'deleted', 'photo', '备忘录', '记录重要事项和想法', NULL, NULL, NULL, '2026-05-17 07:22:39.639295+08', '广东省广州市荔湾区昌华街道昌华苑昌华大街历史文化街区', '广东省广州市荔湾区昌华街道昌华苑昌华大街历史文化街区', 23.1151630, 113.2354350, 0.9200, '{"mode": "image", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "image_url": "http://tmp/OTf77ZUATlZZ959a85ece47c774dbf7e945993be7e4e.jpg", "cover_title": "备忘录，2026-05-16"}', '2026-05-17 07:22:36.076085+08', '2026-05-17 07:23:28.751328+08', '2026-05-17 07:23:28.751328+08');
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('f73fc527-22bc-4f6e-9ca8-a24c741c994a', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'item', 'active', 'photo', '手机正在充电', '手机放在桌上，连着充电线', NULL, NULL, NULL, '2026-05-17 07:23:43.027242+08', '天津市东丽区万新街道程泉道百合春天雪莲北里', '天津市东丽区万新街道程泉道百合春天雪莲北里', 39.1465507, 117.2924286, 0.9200, '{"mode": "image", "scene": "一部手机放在桌子上，连接着充电线。", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "image_url": "http://api-findme.snuday.com/api/assets/media/b6f953aea7144940b49b2e1716a8c451.jpg", "cover_title": "手机正在充电，2026-05-16"}', '2026-05-17 07:23:39.062111+08', '2026-05-17 07:23:39.062111+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('fabe52c3-75ca-49fb-9352-d2c55900e1b0', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'event', 'active', 'voice', '语音备忘录', '语音记录的简要备忘', NULL, NULL, NULL, '2026-05-18 21:26:59.298747+08', '天津市东丽区金钟街道月牙河医院', '天津市东丽区金钟街道月牙河医院', 39.1710819, 117.2586655, 0.9200, '{"mode": "voice", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "audio_url": "http://api-findme.snuday.com/api/assets/media/6e0f4b7e52f748bb9b1beefb39874add.mp3", "cover_title": "语音备忘录，2026-05-18"}', '2026-05-18 21:26:57.329927+08', '2026-05-18 21:26:57.329927+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('70132d31-bc8c-47f2-929e-1f99bd432fe6', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'event', 'active', 'voice', '语音备忘录', '语音记录的简要备忘', NULL, NULL, NULL, '2026-05-18 23:10:00.876148+08', '天津市河东区向阳楼街道上杭花园', '天津市河东区向阳楼街道上杭花园', 39.1433691, 117.2612804, 0.9200, '{"mode": "voice", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "audio_url": "http://api-findme.snuday.com/api/assets/media/fd255e5edfd440a4bb089cd691a5f688.mp3", "cover_title": "语音备忘录，2026-05-18"}', '2026-05-18 23:09:58.967483+08', '2026-05-18 23:09:58.967483+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('a9092dc5-3960-4cae-bec2-6d1f27765691', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'event', 'active', 'voice', '语音备忘录', '语音记录的简要备忘', NULL, NULL, NULL, '2026-05-18 23:11:38.711828+08', '天津市河东区向阳楼街道上杭花园', '天津市河东区向阳楼街道上杭花园', 39.1433691, 117.2612804, 0.9200, '{"mode": "voice", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "audio_url": "http://api-findme.snuday.com/api/assets/media/c89b051c435346a9ae589ab690a4adc6.mp3", "cover_title": "语音备忘录，2026-05-18"}', '2026-05-18 23:11:36.865439+08', '2026-05-18 23:11:36.865439+08', NULL);
INSERT INTO "public"."assets" ("id", "user_id", "asset_type", "status", "source_modality", "title", "summary", "content_text", "event_time_start", "event_time_end", "captured_at", "location_name", "address", "latitude", "longitude", "classify_confidence", "metadata", "created_at", "updated_at", "deleted_at") VALUES ('1433e0db-3fd1-49f5-94ac-25e4a35af700', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'event', 'active', 'voice', '语音备忘录', '语音记录的简要备忘', NULL, NULL, NULL, '2026-05-18 23:15:16.394672+08', '天津市东丽区万新街道崂山道京津国际文化创意产业园', '天津市东丽区万新街道崂山道京津国际文化创意产业园', 39.1408735, 117.2884413, 0.9200, '{"mode": "voice", "ai_stack": ["Qwen", "FastAPI", "Python 3.11"], "audio_url": "http://api-findme.snuday.com/api/assets/media/15bbac640f394f58902fef7babe1a662.mp3", "cover_title": "语音备忘录，2026-05-18"}', '2026-05-18 23:15:13.751542+08', '2026-05-18 23:15:13.751542+08', NULL);
COMMIT;

-- ----------------------------
-- Table structure for llm_call_logs
-- ----------------------------
DROP TABLE IF EXISTS "public"."llm_call_logs";
CREATE TABLE "public"."llm_call_logs" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid,
  "asset_id" uuid,
  "provider" varchar(32) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'qwen'::character varying,
  "model" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "scene" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "prompt_tokens" int4,
  "completion_tokens" int4,
  "total_tokens" int4,
  "latency_ms" int4,
  "request_payload" jsonb,
  "response_payload" jsonb,
  "created_at" timestamptz(6) NOT NULL DEFAULT now()
)
;
ALTER TABLE "public"."llm_call_logs" OWNER TO "findme_user";
COMMENT ON COLUMN "public"."llm_call_logs"."id" IS '日志ID';
COMMENT ON COLUMN "public"."llm_call_logs"."user_id" IS '关联用户ID';
COMMENT ON COLUMN "public"."llm_call_logs"."asset_id" IS '关联资产ID';
COMMENT ON COLUMN "public"."llm_call_logs"."provider" IS '模型提供方';
COMMENT ON COLUMN "public"."llm_call_logs"."model" IS '模型名称';
COMMENT ON COLUMN "public"."llm_call_logs"."scene" IS '调用场景(摘要/标签/问答等)';
COMMENT ON COLUMN "public"."llm_call_logs"."prompt_tokens" IS '输入Token数';
COMMENT ON COLUMN "public"."llm_call_logs"."completion_tokens" IS '输出Token数';
COMMENT ON COLUMN "public"."llm_call_logs"."total_tokens" IS '总Token数';
COMMENT ON COLUMN "public"."llm_call_logs"."latency_ms" IS '调用耗时(毫秒)';
COMMENT ON COLUMN "public"."llm_call_logs"."request_payload" IS '请求体快照(JSON)';
COMMENT ON COLUMN "public"."llm_call_logs"."response_payload" IS '响应体快照(JSON)';
COMMENT ON COLUMN "public"."llm_call_logs"."created_at" IS '创建时间';
COMMENT ON TABLE "public"."llm_call_logs" IS '大模型调用日志表';

-- ----------------------------
-- Records of llm_call_logs
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for tags
-- ----------------------------
DROP TABLE IF EXISTS "public"."tags";
CREATE TABLE "public"."tags" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "owner_user_id" uuid,
  "parent_id" uuid,
  "name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "slug" varchar(128) COLLATE "pg_catalog"."default" NOT NULL,
  "category" varchar(64) COLLATE "pg_catalog"."default",
  "level" int2 NOT NULL DEFAULT 1,
  "is_system" bool NOT NULL DEFAULT false,
  "created_at" timestamptz(6) NOT NULL DEFAULT now(),
  "updated_at" timestamptz(6) NOT NULL DEFAULT now(),
  "hit_count" int8 NOT NULL DEFAULT 0,
  "last_used_at" timestamptz(6)
)
;
ALTER TABLE "public"."tags" OWNER TO "findme_user";
COMMENT ON COLUMN "public"."tags"."id" IS '标签ID';
COMMENT ON COLUMN "public"."tags"."owner_user_id" IS '标签所属用户ID，NULL表示系统标签';
COMMENT ON COLUMN "public"."tags"."parent_id" IS '父标签ID(层级结构)';
COMMENT ON COLUMN "public"."tags"."name" IS '标签名称';
COMMENT ON COLUMN "public"."tags"."slug" IS '标签唯一标识(同用户唯一)';
COMMENT ON COLUMN "public"."tags"."category" IS '标签业务分类';
COMMENT ON COLUMN "public"."tags"."level" IS '标签层级';
COMMENT ON COLUMN "public"."tags"."is_system" IS '是否系统预置标签';
COMMENT ON COLUMN "public"."tags"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."tags"."updated_at" IS '更新时间';
COMMENT ON TABLE "public"."tags" IS '标签表(支持多级标签)';

-- ----------------------------
-- Records of tags
-- ----------------------------
BEGIN;
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('68501304-9dae-4b05-a779-d7f43483120f', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '语音', '语音', 'item', 1, 'f', '2026-05-14 21:39:19.544298+08', '2026-05-18 23:15:13.751542+08', 8, '2026-05-18 23:15:16.394672+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('008e468e-3734-4a5d-ac73-215e9a695c4f', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '事件', '事件', 'item', 1, 'f', '2026-05-14 21:39:19.544298+08', '2026-05-18 23:15:13.751542+08', 8, '2026-05-18 23:15:16.394672+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('75567835-0797-46ff-b8a4-66b81fc6645c', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '办公', '办公', 'item', 1, 'f', '2026-05-14 11:12:23.454029+08', '2026-05-18 21:59:01.791106+08', 6, '2026-05-17 07:23:43.027242+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('49d2ddf6-f05f-49c3-a940-11b32881c358', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '室内', '室内', 'item', 1, 'f', '2026-05-15 18:39:17.52572+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('e960f86a-6b6b-4041-829c-42a310f7b4a4', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '生活', '生活', 'item', 1, 'f', '2026-05-15 18:39:17.52572+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 18:39:23.41496+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('c2417ad5-4aa3-4d67-9e06-40b19ab1b81c', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '个人护理', '个人护理', 'item', 1, 'f', '2026-05-15 18:40:07.847493+08', '2026-05-18 21:59:01.791106+08', 0, '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('ce1af322-958a-475d-8e6f-760fe4a25c50', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '窗户', '窗户', 'item', 1, 'f', '2026-05-15 18:40:07.847493+08', '2026-05-18 21:59:01.791106+08', 0, '2026-05-15 18:40:07.847493+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('e7db3ea2-9b6c-4cc7-9db9-4c18930c461e', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '科技', '科技', 'item', 1, 'f', '2026-05-14 11:12:23.454029+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-14 11:12:27.126012+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('5d9f8372-a8d6-4b8c-8982-26d6f98961a5', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '健康', '健康', 'event', 1, 'f', '2026-05-14 11:44:06.855301+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-14 11:44:09.505283+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('ffeda077-33fd-4d4a-b31d-1ef7c39bdfde', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '家庭', '家庭', 'event', 1, 'f', '2026-05-14 11:44:06.855301+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-14 11:44:09.505283+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('171875ba-c94d-45cc-b327-94a7200d436a', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '医疗', '医疗', 'event', 1, 'f', '2026-05-14 11:44:06.855301+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-14 11:44:09.505283+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('15540471-b486-4014-be42-06d180eceecf', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, 'voice', 'voice', 'event', 1, 'f', '2026-05-18 21:58:54.677196+08', '2026-05-18 21:59:01.791106+08', 2, '2026-05-18 21:26:59.298747+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('247f3a29-0474-422a-880f-288ca694f77d', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, 'memo', 'memo', 'event', 1, 'f', '2026-05-18 21:58:54.677196+08', '2026-05-18 21:59:01.791106+08', 2, '2026-05-18 21:26:59.298747+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('4889f056-7f63-41a4-ab83-106b6c6dbc7b', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '桌面', '桌面', 'item', 1, 'f', '2026-05-18 21:57:58.636669+08', '2026-05-18 21:59:01.791106+08', 2, '2026-05-17 07:23:43.027242+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('4ddf1594-d0aa-4f23-8a33-50fb9e3049ca', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '工作环境', '工作环境', 'item', 1, 'f', '2026-05-18 21:57:58.636669+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 18:49:53.309008+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('be21ab16-e6d5-460c-a32b-44b025b68040', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '购物', '购物', 'item', 1, 'f', '2026-05-14 11:39:51.251029+08', '2026-05-18 21:59:01.791106+08', 0, '2026-05-14 11:39:51.251029+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('a66d3ae8-a49e-44c9-989d-fff33255f1d3', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '生活用品', '生活用品', 'item', 1, 'f', '2026-05-14 11:39:51.251029+08', '2026-05-18 21:59:01.791106+08', 0, '2026-05-14 11:39:51.251029+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('43d4d39d-1e12-4708-88d2-42ed054656d5', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '食品', '食品', 'item', 1, 'f', '2026-05-14 11:39:51.251029+08', '2026-05-18 21:59:01.791106+08', 0, '2026-05-14 11:39:51.251029+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('b30c9314-ad46-486b-b92d-764aef204aa4', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '电子设备', '电子设备', 'item', 1, 'f', '2026-05-14 17:20:56.162199+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-14 17:21:01.889329+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('6bc34c8c-d639-415b-9e96-edbed1460204', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '建筑', '建筑', 'item', 1, 'f', '2026-05-15 17:54:49.958018+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 17:54:54.817886+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('4f52efc4-ac87-4546-bb8d-19781ef12273', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '现代', '现代', 'item', 1, 'f', '2026-05-15 17:54:49.958018+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 17:54:54.817886+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('7af3cc56-9f37-4de1-afce-a6596b770e17', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '备忘录', '备忘录', 'item', 1, 'f', '2026-05-14 11:35:31.122951+08', '2026-05-18 21:59:01.791106+08', 6, '2026-05-17 07:23:43.027242+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('c4769c3f-a0ef-4e4f-b614-69fdc8f942f0', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '卧室', '卧室', 'item', 1, 'f', '2026-05-15 18:56:17.914977+08', '2026-05-18 21:59:01.791106+08', 0, '2026-05-15 18:56:17.914977+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('de10d8e7-c14f-48d3-9b75-af213ec3a70d', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '视频', '视频', 'item', 1, 'f', '2026-05-15 08:46:14.114465+08', '2026-05-18 21:59:01.791106+08', 0, '2026-05-15 08:46:14.114465+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('dc1dfc55-ec06-4be7-b04d-fff4bdb5f4ca', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '物品', '物品', 'item', 1, 'f', '2026-05-15 08:46:14.114465+08', '2026-05-18 21:59:01.791106+08', 0, '2026-05-15 08:46:14.114465+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('ee53a7d5-4646-4d05-b86d-8019f4dd02a3', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '杂乱', '杂乱', 'item', 1, 'f', '2026-05-18 21:58:10.391498+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 18:39:23.41496+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('c914f975-e1f6-4f71-9ec7-0419448bd6b4', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '生活场景', '生活场景', 'item', 1, 'f', '2026-05-18 21:58:10.391498+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 18:39:23.41496+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('c6ed4375-4fc5-4c1c-9091-dd1d1c6759f0', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '家居', '家居', 'item', 1, 'f', '2026-05-15 18:39:17.52572+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 18:56:17.914977+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('6bf68d85-ca2d-48ae-9a11-d731b8e4e4c0', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '现代建筑', '现代建筑', 'item', 1, 'f', '2026-05-18 21:58:16.095612+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 17:54:54.817886+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('a64c2bc4-1b14-4330-9cf4-e7b4647c3c3b', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '外景', '外景', 'item', 1, 'f', '2026-05-18 21:58:16.095612+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 17:54:54.817886+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('51262a2f-b8bc-4b9e-8da4-f82536521d75', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '道路', '道路', 'item', 1, 'f', '2026-05-18 21:58:16.095612+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 17:54:54.817886+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('b1ba7601-9541-4809-81bb-a80ddd735293', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '树木', '树木', 'item', 1, 'f', '2026-05-18 21:58:16.095612+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-15 17:54:54.817886+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('80d1bea1-6e0a-48d3-b49a-c8bb85d72575', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '充电', '充电', 'item', 1, 'f', '2026-05-18 21:58:22.863621+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-17 07:23:43.027242+08');
INSERT INTO "public"."tags" ("id", "owner_user_id", "parent_id", "name", "slug", "category", "level", "is_system", "created_at", "updated_at", "hit_count", "last_used_at") VALUES ('0734fb0e-8e59-4811-979e-0ceb9539d9cf', 'df676488-6d42-4f18-b749-35f0dc461b9e', NULL, '手机', '手机', 'item', 1, 'f', '2026-05-18 21:58:22.863621+08', '2026-05-18 21:59:01.791106+08', 1, '2026-05-17 07:23:43.027242+08');
COMMIT;

-- ----------------------------
-- Table structure for user_auth_accounts
-- ----------------------------
DROP TABLE IF EXISTS "public"."user_auth_accounts";
CREATE TABLE "public"."user_auth_accounts" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "provider" varchar(32) COLLATE "pg_catalog"."default" NOT NULL,
  "provider_user_id" varchar(128) COLLATE "pg_catalog"."default" NOT NULL,
  "union_id" varchar(128) COLLATE "pg_catalog"."default",
  "open_id" varchar(128) COLLATE "pg_catalog"."default",
  "app_id" varchar(64) COLLATE "pg_catalog"."default",
  "extra" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "created_at" timestamptz(6) NOT NULL DEFAULT now(),
  "updated_at" timestamptz(6) NOT NULL DEFAULT now()
)
;
ALTER TABLE "public"."user_auth_accounts" OWNER TO "findme_user";
COMMENT ON COLUMN "public"."user_auth_accounts"."id" IS '绑定记录ID';
COMMENT ON COLUMN "public"."user_auth_accounts"."user_id" IS '关联用户ID';
COMMENT ON COLUMN "public"."user_auth_accounts"."provider" IS '授权提供方，如wechat';
COMMENT ON COLUMN "public"."user_auth_accounts"."provider_user_id" IS '第三方平台用户唯一标识';
COMMENT ON COLUMN "public"."user_auth_accounts"."union_id" IS '微信UnionID';
COMMENT ON COLUMN "public"."user_auth_accounts"."open_id" IS '微信OpenID';
COMMENT ON COLUMN "public"."user_auth_accounts"."app_id" IS '应用ID';
COMMENT ON COLUMN "public"."user_auth_accounts"."extra" IS '扩展授权信息(JSON)';
COMMENT ON COLUMN "public"."user_auth_accounts"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."user_auth_accounts"."updated_at" IS '更新时间';
COMMENT ON TABLE "public"."user_auth_accounts" IS '第三方授权账号绑定表(如微信)';

-- ----------------------------
-- Records of user_auth_accounts
-- ----------------------------
BEGIN;
INSERT INTO "public"."user_auth_accounts" ("id", "user_id", "provider", "provider_user_id", "union_id", "open_id", "app_id", "extra", "created_at", "updated_at") VALUES ('5d401d50-df29-45d6-a123-2bab62876d60', 'f38c8b17-bb59-4da9-8823-b5812bc633c2', 'wechat', 'oHotl3ViNkoGk-V7B09qFr7Cz3Oo', NULL, 'oHotl3ViNkoGk-V7B09qFr7Cz3Oo', 'wx2a35abd7d3304a98', '{"session_key_sha256": "556b151f1bbfb947ddf8ecc4d69fefa6873d28362bb222e8482a4902e6879bad"}', '2026-05-15 19:27:06.965839+08', '2026-05-15 19:27:15.89996+08');
INSERT INTO "public"."user_auth_accounts" ("id", "user_id", "provider", "provider_user_id", "union_id", "open_id", "app_id", "extra", "created_at", "updated_at") VALUES ('4daa0fe1-77d4-4813-9440-6789ba4667fa', 'ff5576ce-cc54-485f-ae34-72ca784dacc2', 'wechat', 'oHotl3TvVsMEbDogejSDbo9UPIyw', NULL, 'oHotl3TvVsMEbDogejSDbo9UPIyw', 'wx2a35abd7d3304a98', '{"session_key_sha256": "6309f0a28652189ffd8ddb30c98007a784f72ffead74a17a8616f680ecfd8f4a"}', '2026-05-15 15:05:27.840238+08', '2026-05-16 04:14:30.785638+08');
INSERT INTO "public"."user_auth_accounts" ("id", "user_id", "provider", "provider_user_id", "union_id", "open_id", "app_id", "extra", "created_at", "updated_at") VALUES ('0ccc4772-17ca-401f-a0e0-1d5ce36be8af', 'b1c9e26a-1f2c-414e-ad92-f9cb1d1fd1df', 'wechat', 'oHotl3QK0tXUKtW8BeCi_0Q7GR6s', NULL, 'oHotl3QK0tXUKtW8BeCi_0Q7GR6s', 'wx2a35abd7d3304a98', '{"session_key_sha256": "408e8469e05ed7adf6153afd648fba218f1db3e90aaea449f17ad3fdd5ec7504"}', '2026-05-15 15:05:27.841239+08', '2026-05-16 04:14:32.108679+08');
INSERT INTO "public"."user_auth_accounts" ("id", "user_id", "provider", "provider_user_id", "union_id", "open_id", "app_id", "extra", "created_at", "updated_at") VALUES ('c8bcc198-fbe1-4695-96e3-1527e4ec2036', '6e8006cf-8dba-4c4c-b780-9acd2edae022', 'wechat', 'oHotl3eAKix6tNl4VEijn_eikoMY', NULL, 'oHotl3eAKix6tNl4VEijn_eikoMY', 'wx2a35abd7d3304a98', '{"session_key_sha256": "bd822d9736b223b08765f353b332d95894e2aeff1d94a04b8e20e81d72e93c37"}', '2026-05-16 10:20:29.023666+08', '2026-05-16 10:20:29.023666+08');
INSERT INTO "public"."user_auth_accounts" ("id", "user_id", "provider", "provider_user_id", "union_id", "open_id", "app_id", "extra", "created_at", "updated_at") VALUES ('1be6aece-f313-4c16-aae3-34eb87981286', '23798c18-f1ce-4eec-8e81-b6bbb57175b7', 'wechat', 'oHotl3fTRzYm9oU8CdZ9QboW_gGg', NULL, 'oHotl3fTRzYm9oU8CdZ9QboW_gGg', 'wx2a35abd7d3304a98', '{"session_key_sha256": "e2d66e78b3eb53c146b80740a785149657aa8d45bf055109d3808f2c6737224f"}', '2026-05-16 15:54:28.698472+08', '2026-05-16 15:54:28.698472+08');
INSERT INTO "public"."user_auth_accounts" ("id", "user_id", "provider", "provider_user_id", "union_id", "open_id", "app_id", "extra", "created_at", "updated_at") VALUES ('b6c50001-4398-4b3f-9f9f-63da83288db6', 'e3b0ad85-b6d0-4f0d-b179-d1921e069885', 'wechat', 'oHotl3R7Nh-LyWirgqpPti8Ozgd0', NULL, 'oHotl3R7Nh-LyWirgqpPti8Ozgd0', 'wx2a35abd7d3304a98', '{"session_key_sha256": "57fcf60b85d14590540103ae996438f73aac39dd06de0e90ff12da6a35e3093b"}', '2026-05-15 15:05:18.573986+08', '2026-05-15 15:05:18.573986+08');
INSERT INTO "public"."user_auth_accounts" ("id", "user_id", "provider", "provider_user_id", "union_id", "open_id", "app_id", "extra", "created_at", "updated_at") VALUES ('e0feee2b-4617-4678-a33c-e57b994f7963', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'wechat', 'oHotl3VqywCL1ryX6CWduIkw4b3g', NULL, 'oHotl3VqywCL1ryX6CWduIkw4b3g', 'wx2a35abd7d3304a98', '{"session_key_sha256": "6d45c8de533fb5184bcbe9ae2200893cf3508e8eea1f8170d45d089ffc72f5a3"}', '2026-05-14 11:12:01.100082+08', '2026-05-18 22:31:53.570018+08');
COMMIT;

-- ----------------------------
-- Table structure for user_sessions
-- ----------------------------
DROP TABLE IF EXISTS "public"."user_sessions";
CREATE TABLE "public"."user_sessions" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "token" varchar(256) COLLATE "pg_catalog"."default" NOT NULL,
  "client_type" varchar(32) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'miniprogram'::character varying,
  "expires_at" timestamptz(6) NOT NULL,
  "last_seen_at" timestamptz(6),
  "created_at" timestamptz(6) NOT NULL DEFAULT now()
)
;
ALTER TABLE "public"."user_sessions" OWNER TO "findme_user";
COMMENT ON COLUMN "public"."user_sessions"."id" IS '会话ID';
COMMENT ON COLUMN "public"."user_sessions"."user_id" IS '关联用户ID';
COMMENT ON COLUMN "public"."user_sessions"."token" IS '登录令牌';
COMMENT ON COLUMN "public"."user_sessions"."client_type" IS '客户端类型(miniprogram/web/app)';
COMMENT ON COLUMN "public"."user_sessions"."expires_at" IS '会话过期时间';
COMMENT ON COLUMN "public"."user_sessions"."last_seen_at" IS '最后活跃时间';
COMMENT ON COLUMN "public"."user_sessions"."created_at" IS '创建时间';
COMMENT ON TABLE "public"."user_sessions" IS '用户登录会话表';

-- ----------------------------
-- Records of user_sessions
-- ----------------------------
BEGIN;
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('c1dbab29-1974-451c-aea3-1bbc9cd4fae5', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_FskbNzaQ5guzjeEy90NNsrcwZJ0yfAD1', 'miniprogram', '2026-05-21 11:12:01.120281+08', '2026-05-14 11:12:01.100082+08', '2026-05-14 11:12:01.100082+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('7371c052-3662-49f2-92eb-7d58d97a5d97', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_cfFFsZCM4turuTOpm6XlpwS4Hjra0D2t', 'miniprogram', '2026-05-21 11:14:35.805359+08', '2026-05-14 11:14:35.797374+08', '2026-05-14 11:14:35.797374+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('1298798e-af1a-4075-b461-d68f1cee5c04', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_4YJQFxzVk1raKBHBqCx5QeGSTBMySy2n', 'miniprogram', '2026-05-21 11:35:17.533977+08', '2026-05-14 11:35:17.538694+08', '2026-05-14 11:35:17.538694+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('193f8661-0bf6-408f-9012-0eba7867642f', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_lfNORA3DBAVxhiJJsfZaTT14-h25IWhM', 'miniprogram', '2026-05-21 14:04:25.649836+08', '2026-05-14 14:04:25.653742+08', '2026-05-14 14:04:25.653742+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('d23d2a91-e3c7-4a4f-9de7-b5b0b1393e27', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_ED_5hN1o2AzMEp8MJ0pcFFTv6bwXfVTs', 'miniprogram', '2026-05-21 16:32:53.121009+08', '2026-05-14 16:32:53.120869+08', '2026-05-14 16:32:53.120869+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('1f1bea7f-dc6f-45ab-aef4-60431da7ad24', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_0YZWG81o9Dixzx2zmkjiA922zKEO8Fyp', 'miniprogram', '2026-05-21 17:03:43.86931+08', '2026-05-14 17:03:43.853611+08', '2026-05-14 17:03:43.853611+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('8c32a2e7-04c0-4a9e-9651-76efeba1c7de', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_M_q5J7iIRGTmqoYV0j7S-GiD76ux-5Vg', 'miniprogram', '2026-05-21 17:20:26.779986+08', '2026-05-14 17:20:26.76428+08', '2026-05-14 17:20:26.76428+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('eea90b21-e458-4c46-b702-f468eaf8f33d', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_rXjN22-jICcxdroXHmW6NqFy8kmmeTgn', 'miniprogram', '2026-05-22 08:43:11.177368+08', '2026-05-15 08:43:11.164037+08', '2026-05-15 08:43:11.164037+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('5c327436-f15e-455a-856d-897ad4819cdb', 'e3b0ad85-b6d0-4f0d-b179-d1921e069885', 'fmb_XH4q33k_xAaVAVLlq0JzbSgdQOjgnSV0', 'miniprogram', '2026-05-22 15:05:18.58152+08', '2026-05-15 15:05:18.573986+08', '2026-05-15 15:05:18.573986+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('f77c46ee-4146-4349-aec7-7d0eb1bfdabd', 'b1c9e26a-1f2c-414e-ad92-f9cb1d1fd1df', 'fmb_Qb0DV2NZBwGKrF4--mG05cw6y_oBmAht', 'miniprogram', '2026-05-22 15:05:27.84718+08', '2026-05-15 15:05:27.841239+08', '2026-05-15 15:05:27.841239+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('5520c547-d278-42f4-aae7-3ed09a07fd08', 'ff5576ce-cc54-485f-ae34-72ca784dacc2', 'fmb_DpeCZBf2YKimctN-qVXvYdpYnKgqozRv', 'miniprogram', '2026-05-22 15:05:27.862809+08', '2026-05-15 15:05:27.840238+08', '2026-05-15 15:05:27.840238+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('b6e57ebf-c374-4760-b775-2a418f084700', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_CwcstjFx_k6FCTcwYUZk6CkH8ZYAYmVH', 'miniprogram', '2026-05-22 15:10:12.460748+08', '2026-05-15 15:10:12.449802+08', '2026-05-15 15:10:12.449802+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('f5a231d4-5a29-43da-bd33-5f0f2597190b', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_8pVsS9g9chCEOB5cPny13PDeJJUWoG_9', 'miniprogram', '2026-05-22 19:06:46.095025+08', '2026-05-15 19:06:46.088032+08', '2026-05-15 19:06:46.088032+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('6ffa5f13-875e-474c-bd05-625246564a9f', 'f38c8b17-bb59-4da9-8823-b5812bc633c2', 'fmb_IbLIwYlz4B3v8QyDzDf9L6tNzxIESZK2', 'miniprogram', '2026-05-22 19:27:06.972584+08', '2026-05-15 19:27:06.965839+08', '2026-05-15 19:27:06.965839+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('469cbfc0-9b53-44bc-b2a6-79052c48afa2', 'f38c8b17-bb59-4da9-8823-b5812bc633c2', 'fmb_s0edmHDTEZahp1pGtGumV-zxge40IZEa', 'miniprogram', '2026-05-22 19:27:15.910124+08', '2026-05-15 19:27:15.89996+08', '2026-05-15 19:27:15.89996+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('139fa481-2475-4edc-bb79-13f8ea91b84a', 'ff5576ce-cc54-485f-ae34-72ca784dacc2', 'fmb_LLQQXRPSiGYZ4fluhrusAedU9ozPIMlk', 'miniprogram', '2026-05-22 19:27:15.925753+08', '2026-05-15 19:27:15.926203+08', '2026-05-15 19:27:15.926203+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('f03dfac2-1168-4c45-806a-0afe5f7be974', 'ff5576ce-cc54-485f-ae34-72ca784dacc2', 'fmb_VDGJJ_yoCTPctrQo5c620dkYVuFH-kjw', 'miniprogram', '2026-05-23 04:14:30.802492+08', '2026-05-16 04:14:30.785638+08', '2026-05-16 04:14:30.785638+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('87a959d4-977d-48d3-82d9-b47b4d96cef3', 'b1c9e26a-1f2c-414e-ad92-f9cb1d1fd1df', 'fmb_qqQj4oApRF9XgtCI0kfQhOTINzmHCV8M', 'miniprogram', '2026-05-23 04:14:32.114978+08', '2026-05-16 04:14:32.108679+08', '2026-05-16 04:14:32.108679+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('65bc4421-b254-4f22-a68a-95512d0793cd', '6e8006cf-8dba-4c4c-b780-9acd2edae022', 'fmb_rpJdJ_OcP1SB2Kzmp7D7eaaqD7yGjbCH', 'miniprogram', '2026-05-23 10:20:29.047902+08', '2026-05-16 10:20:29.023666+08', '2026-05-16 10:20:29.023666+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('4df68680-3440-4d41-ae13-eaa8354df354', '23798c18-f1ce-4eec-8e81-b6bbb57175b7', 'fmb_36N44SLxE5BDmAq4yCuxhNzvX8Ogr97q', 'miniprogram', '2026-05-23 15:54:28.722549+08', '2026-05-16 15:54:28.698472+08', '2026-05-16 15:54:28.698472+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('6613f520-25fd-4644-81c8-7cd02b6fcad1', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_o0F9x9cYLaFAqS_qdr3VbmgcNbYqAyPi', 'miniprogram', '2026-05-24 07:08:09.997716+08', '2026-05-17 07:08:09.985403+08', '2026-05-17 07:08:09.985403+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('e7289479-34f8-4f36-b6de-52c5c1e22c48', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_fGqrpODQpNnK21ZYaYeEa2uXhzIyV60l', 'miniprogram', '2026-05-24 07:22:18.284848+08', '2026-05-17 07:22:18.276621+08', '2026-05-17 07:22:18.276621+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('4de696b7-d31c-4b22-a330-9a225b211503', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_HXyDBv_WuJi2H16y1H1QJjozg6ZRVzJi', 'miniprogram', '2026-05-25 21:39:30.337572+08', '2026-05-18 21:39:30.472546+08', '2026-05-18 21:39:30.472546+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('21240448-8416-4a24-ad2f-4336e7c6e071', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_9fPJ3dqM8BL88Adl2La7XxLlId6qRdup', 'miniprogram', '2026-05-25 21:41:43.25987+08', '2026-05-18 21:41:43.404946+08', '2026-05-18 21:41:43.404946+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('67c1d774-a831-4051-b575-4bac99817be3', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_CCqq054niD3e-b575yfZUFF-W7MxNBN-', 'miniprogram', '2026-05-25 21:48:23.053348+08', '2026-05-18 21:48:23.189525+08', '2026-05-18 21:48:23.189525+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('d3d7a413-e7d7-4492-882e-b2fd796bb92a', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_6PsKmqK9cFVwI2qVH-Xgi6nb_WyUX0xT', 'miniprogram', '2026-05-25 21:57:10.142175+08', '2026-05-18 21:57:10.27751+08', '2026-05-18 21:57:10.27751+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('6ec69896-8df9-48af-a674-41d742405deb', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb__K6SyqKBEHF5l1yXn__dLgVTjrA6rOBj', 'miniprogram', '2026-05-25 22:03:13.643613+08', '2026-05-18 22:03:13.77947+08', '2026-05-18 22:03:13.77947+08');
INSERT INTO "public"."user_sessions" ("id", "user_id", "token", "client_type", "expires_at", "last_seen_at", "created_at") VALUES ('10d9738f-bfb4-4a1b-b53c-efd4b673be02', 'df676488-6d42-4f18-b749-35f0dc461b9e', 'fmb_IZ9NMbMBTndPvzYtGy9mlWW31J5U-NNL', 'miniprogram', '2026-05-25 22:31:53.436466+08', '2026-05-18 22:31:53.570018+08', '2026-05-18 22:31:53.570018+08');
COMMIT;

-- ----------------------------
-- Table structure for user_sync_settings
-- ----------------------------
DROP TABLE IF EXISTS "public"."user_sync_settings";
CREATE TABLE "public"."user_sync_settings" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "oss_enabled" bool NOT NULL DEFAULT false,
  "oss_provider" varchar(32) COLLATE "pg_catalog"."default",
  "oss_bucket" varchar(128) COLLATE "pg_catalog"."default",
  "oss_endpoint" varchar(255) COLLATE "pg_catalog"."default",
  "db_backup_enabled" bool NOT NULL DEFAULT false,
  "db_backup_cron" varchar(64) COLLATE "pg_catalog"."default",
  "encrypted_config" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "created_at" timestamptz(6) NOT NULL DEFAULT now(),
  "updated_at" timestamptz(6) NOT NULL DEFAULT now()
)
;
ALTER TABLE "public"."user_sync_settings" OWNER TO "findme_user";
COMMENT ON COLUMN "public"."user_sync_settings"."id" IS '配置ID';
COMMENT ON COLUMN "public"."user_sync_settings"."user_id" IS '用户ID(唯一)';
COMMENT ON COLUMN "public"."user_sync_settings"."oss_enabled" IS '是否启用OSS同步';
COMMENT ON COLUMN "public"."user_sync_settings"."oss_provider" IS 'OSS提供商';
COMMENT ON COLUMN "public"."user_sync_settings"."oss_bucket" IS 'OSS桶名称';
COMMENT ON COLUMN "public"."user_sync_settings"."oss_endpoint" IS 'OSS访问端点';
COMMENT ON COLUMN "public"."user_sync_settings"."db_backup_enabled" IS '是否启用数据库备份';
COMMENT ON COLUMN "public"."user_sync_settings"."db_backup_cron" IS '备份任务CRON表达式';
COMMENT ON COLUMN "public"."user_sync_settings"."encrypted_config" IS '加密配置(JSON)';
COMMENT ON COLUMN "public"."user_sync_settings"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."user_sync_settings"."updated_at" IS '更新时间';
COMMENT ON TABLE "public"."user_sync_settings" IS '用户同步与备份配置表';

-- ----------------------------
-- Records of user_sync_settings
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS "public"."users";
CREATE TABLE "public"."users" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "nickname" varchar(64) COLLATE "pg_catalog"."default" NOT NULL DEFAULT '记忆守护者'::character varying,
  "avatar_url" text COLLATE "pg_catalog"."default",
  "phone" varchar(32) COLLATE "pg_catalog"."default",
  "locale" varchar(16) COLLATE "pg_catalog"."default" DEFAULT 'zh-CN'::character varying,
  "timezone" varchar(64) COLLATE "pg_catalog"."default" DEFAULT 'Asia/Shanghai'::character varying,
  "is_active" bool NOT NULL DEFAULT true,
  "created_at" timestamptz(6) NOT NULL DEFAULT now(),
  "updated_at" timestamptz(6) NOT NULL DEFAULT now()
)
;
ALTER TABLE "public"."users" OWNER TO "findme_user";
COMMENT ON COLUMN "public"."users"."id" IS '用户ID(UUID主键)';
COMMENT ON COLUMN "public"."users"."nickname" IS '用户昵称';
COMMENT ON COLUMN "public"."users"."avatar_url" IS '头像URL';
COMMENT ON COLUMN "public"."users"."phone" IS '手机号(可选)';
COMMENT ON COLUMN "public"."users"."locale" IS '语言区域设置';
COMMENT ON COLUMN "public"."users"."timezone" IS '时区';
COMMENT ON COLUMN "public"."users"."is_active" IS '是否启用账号';
COMMENT ON COLUMN "public"."users"."created_at" IS '创建时间';
COMMENT ON COLUMN "public"."users"."updated_at" IS '更新时间';
COMMENT ON TABLE "public"."users" IS '用户主表';

-- ----------------------------
-- Records of users
-- ----------------------------
BEGIN;
INSERT INTO "public"."users" ("id", "nickname", "avatar_url", "phone", "locale", "timezone", "is_active", "created_at", "updated_at") VALUES ('df676488-6d42-4f18-b749-35f0dc461b9e', '鹏', 'wxfile://tmp_0c464393bde0699ac5b16a2c2d833436.jpg', NULL, 'zh-CN', 'Asia/Shanghai', 't', '2026-05-14 11:12:01.100082+08', '2026-05-14 17:28:28.783297+08');
INSERT INTO "public"."users" ("id", "nickname", "avatar_url", "phone", "locale", "timezone", "is_active", "created_at", "updated_at") VALUES ('e3b0ad85-b6d0-4f0d-b179-d1921e069885', '记忆守护者', NULL, NULL, 'zh-CN', 'Asia/Shanghai', 't', '2026-05-15 15:05:18.573986+08', '2026-05-15 15:05:18.573986+08');
INSERT INTO "public"."users" ("id", "nickname", "avatar_url", "phone", "locale", "timezone", "is_active", "created_at", "updated_at") VALUES ('b1c9e26a-1f2c-414e-ad92-f9cb1d1fd1df', '记忆守护者', NULL, NULL, 'zh-CN', 'Asia/Shanghai', 't', '2026-05-15 15:05:27.841239+08', '2026-05-15 15:05:27.841239+08');
INSERT INTO "public"."users" ("id", "nickname", "avatar_url", "phone", "locale", "timezone", "is_active", "created_at", "updated_at") VALUES ('ff5576ce-cc54-485f-ae34-72ca784dacc2', '记忆守护者', NULL, NULL, 'zh-CN', 'Asia/Shanghai', 't', '2026-05-15 15:05:27.840238+08', '2026-05-15 15:05:27.840238+08');
INSERT INTO "public"."users" ("id", "nickname", "avatar_url", "phone", "locale", "timezone", "is_active", "created_at", "updated_at") VALUES ('f38c8b17-bb59-4da9-8823-b5812bc633c2', '记忆守护者', NULL, NULL, 'zh-CN', 'Asia/Shanghai', 't', '2026-05-15 19:27:06.965839+08', '2026-05-15 19:27:06.965839+08');
INSERT INTO "public"."users" ("id", "nickname", "avatar_url", "phone", "locale", "timezone", "is_active", "created_at", "updated_at") VALUES ('6e8006cf-8dba-4c4c-b780-9acd2edae022', '记忆守护者', NULL, NULL, 'zh-CN', 'Asia/Shanghai', 't', '2026-05-16 10:20:29.023666+08', '2026-05-16 10:20:29.023666+08');
INSERT INTO "public"."users" ("id", "nickname", "avatar_url", "phone", "locale", "timezone", "is_active", "created_at", "updated_at") VALUES ('23798c18-f1ce-4eec-8e81-b6bbb57175b7', '记忆守护者', NULL, NULL, 'zh-CN', 'Asia/Shanghai', 't', '2026-05-16 15:54:28.698472+08', '2026-05-16 15:54:28.698472+08');
COMMIT;

-- ----------------------------
-- Function structure for armor
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."armor"(bytea, _text, _text);
CREATE OR REPLACE FUNCTION "public"."armor"(bytea, _text, _text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pg_armor'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."armor"(bytea, _text, _text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for armor
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."armor"(bytea);
CREATE OR REPLACE FUNCTION "public"."armor"(bytea)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pg_armor'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."armor"(bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for array_to_vector
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."array_to_vector"(_float8, int4, bool);
CREATE OR REPLACE FUNCTION "public"."array_to_vector"(_float8, int4, bool)
  RETURNS "public"."vector" AS '$libdir/vector', 'array_to_vector'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."array_to_vector"(_float8, int4, bool) OWNER TO "postgres";

-- ----------------------------
-- Function structure for array_to_vector
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."array_to_vector"(_int4, int4, bool);
CREATE OR REPLACE FUNCTION "public"."array_to_vector"(_int4, int4, bool)
  RETURNS "public"."vector" AS '$libdir/vector', 'array_to_vector'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."array_to_vector"(_int4, int4, bool) OWNER TO "postgres";

-- ----------------------------
-- Function structure for array_to_vector
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."array_to_vector"(_float4, int4, bool);
CREATE OR REPLACE FUNCTION "public"."array_to_vector"(_float4, int4, bool)
  RETURNS "public"."vector" AS '$libdir/vector', 'array_to_vector'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."array_to_vector"(_float4, int4, bool) OWNER TO "postgres";

-- ----------------------------
-- Function structure for array_to_vector
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."array_to_vector"(_numeric, int4, bool);
CREATE OR REPLACE FUNCTION "public"."array_to_vector"(_numeric, int4, bool)
  RETURNS "public"."vector" AS '$libdir/vector', 'array_to_vector'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."array_to_vector"(_numeric, int4, bool) OWNER TO "postgres";

-- ----------------------------
-- Function structure for cosine_distance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."cosine_distance"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."cosine_distance"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."float8" AS '$libdir/vector', 'cosine_distance'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."cosine_distance"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for crypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."crypt"(text, text);
CREATE OR REPLACE FUNCTION "public"."crypt"(text, text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pg_crypt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."crypt"(text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for dearmor
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."dearmor"(text);
CREATE OR REPLACE FUNCTION "public"."dearmor"(text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_dearmor'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."dearmor"(text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."decrypt"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."decrypt"(bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_decrypt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."decrypt"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for decrypt_iv
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."decrypt_iv"(bytea, bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."decrypt_iv"(bytea, bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_decrypt_iv'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."decrypt_iv"(bytea, bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for digest
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."digest"(text, text);
CREATE OR REPLACE FUNCTION "public"."digest"(text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_digest'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."digest"(text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for digest
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."digest"(bytea, text);
CREATE OR REPLACE FUNCTION "public"."digest"(bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_digest'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."digest"(bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for encrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."encrypt"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."encrypt"(bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_encrypt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."encrypt"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for encrypt_iv
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."encrypt_iv"(bytea, bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."encrypt_iv"(bytea, bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_encrypt_iv'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."encrypt_iv"(bytea, bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for gen_random_bytes
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gen_random_bytes"(int4);
CREATE OR REPLACE FUNCTION "public"."gen_random_bytes"(int4)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_random_bytes'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."gen_random_bytes"(int4) OWNER TO "postgres";

-- ----------------------------
-- Function structure for gen_random_uuid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gen_random_uuid"();
CREATE OR REPLACE FUNCTION "public"."gen_random_uuid"()
  RETURNS "pg_catalog"."uuid" AS '$libdir/pgcrypto', 'pg_random_uuid'
  LANGUAGE c VOLATILE
  COST 1;
ALTER FUNCTION "public"."gen_random_uuid"() OWNER TO "postgres";

-- ----------------------------
-- Function structure for gen_salt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gen_salt"(text, int4);
CREATE OR REPLACE FUNCTION "public"."gen_salt"(text, int4)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pg_gen_salt_rounds'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."gen_salt"(text, int4) OWNER TO "postgres";

-- ----------------------------
-- Function structure for gen_salt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gen_salt"(text);
CREATE OR REPLACE FUNCTION "public"."gen_salt"(text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pg_gen_salt'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."gen_salt"(text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for hmac
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."hmac"(text, text, text);
CREATE OR REPLACE FUNCTION "public"."hmac"(text, text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_hmac'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."hmac"(text, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for hmac
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."hmac"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."hmac"(bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_hmac'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."hmac"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for inner_product
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."inner_product"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."inner_product"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."float8" AS '$libdir/vector', 'inner_product'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."inner_product"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for ivfflathandler
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."ivfflathandler"(internal);
CREATE OR REPLACE FUNCTION "public"."ivfflathandler"(internal)
  RETURNS "pg_catalog"."index_am_handler" AS '$libdir/vector', 'ivfflathandler'
  LANGUAGE c VOLATILE
  COST 1;
ALTER FUNCTION "public"."ivfflathandler"(internal) OWNER TO "postgres";

-- ----------------------------
-- Function structure for l2_distance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."l2_distance"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."l2_distance"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."float8" AS '$libdir/vector', 'l2_distance'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."l2_distance"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_armor_headers
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_armor_headers"(text, OUT "key" text, OUT "value" text);
CREATE OR REPLACE FUNCTION "public"."pgp_armor_headers"(IN text, OUT "key" text, OUT "value" text)
  RETURNS SETOF "pg_catalog"."record" AS '$libdir/pgcrypto', 'pgp_armor_headers'
  LANGUAGE c IMMUTABLE STRICT
  COST 1
  ROWS 1000;
ALTER FUNCTION "public"."pgp_armor_headers"(text, OUT "key" text, OUT "value" text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_key_id
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_key_id"(bytea);
CREATE OR REPLACE FUNCTION "public"."pgp_key_id"(bytea)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_key_id_w'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_key_id"(bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea, text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt"(bytea, bytea, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea, text, text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt"(bytea, bytea);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt_bytea"(bytea, bytea);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_encrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_encrypt"(text, bytea);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_encrypt"(text, bytea)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_encrypt"(text, bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_encrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_encrypt"(text, bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_encrypt"(text, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_encrypt"(text, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_encrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_encrypt_bytea"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_encrypt_bytea"(bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_encrypt_bytea"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_encrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_encrypt_bytea"(bytea, bytea);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_encrypt_bytea"(bytea, bytea)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_encrypt_bytea"(bytea, bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_decrypt"(bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_decrypt"(bytea, text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_decrypt"(bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_decrypt"(bytea, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_decrypt"(bytea, text, text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_decrypt"(bytea, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_decrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_decrypt_bytea"(bytea, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_decrypt_bytea"(bytea, text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_decrypt_bytea"(bytea, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_decrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_decrypt_bytea"(bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_decrypt_bytea"(bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_decrypt_bytea"(bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_encrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_encrypt"(text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_encrypt"(text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_encrypt"(text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_encrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_encrypt"(text, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_encrypt"(text, text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_encrypt"(text, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_encrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_encrypt_bytea"(bytea, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_encrypt_bytea"(bytea, text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_encrypt_bytea"(bytea, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_encrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_encrypt_bytea"(bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_encrypt_bytea"(bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_encrypt_bytea"(bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for set_updated_at
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."set_updated_at"();
CREATE OR REPLACE FUNCTION "public"."set_updated_at"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "public"."set_updated_at"() OWNER TO "findme_user";

-- ----------------------------
-- Function structure for vector
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector"("public"."vector", int4, bool);
CREATE OR REPLACE FUNCTION "public"."vector"("public"."vector", int4, bool)
  RETURNS "public"."vector" AS '$libdir/vector', 'vector'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector"("public"."vector", int4, bool) OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_accum
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_accum"(_float8, "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_accum"(_float8, "public"."vector")
  RETURNS "pg_catalog"."_float8" AS '$libdir/vector', 'vector_accum'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_accum"(_float8, "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_add
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_add"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_add"("public"."vector", "public"."vector")
  RETURNS "public"."vector" AS '$libdir/vector', 'vector_add'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_add"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_avg
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_avg"(_float8);
CREATE OR REPLACE FUNCTION "public"."vector_avg"(_float8)
  RETURNS "public"."vector" AS '$libdir/vector', 'vector_avg'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_avg"(_float8) OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_cmp
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_cmp"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_cmp"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."int4" AS '$libdir/vector', 'vector_cmp'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_cmp"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_combine
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_combine"(_float8, _float8);
CREATE OR REPLACE FUNCTION "public"."vector_combine"(_float8, _float8)
  RETURNS "pg_catalog"."_float8" AS '$libdir/vector', 'vector_combine'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_combine"(_float8, _float8) OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_dims
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_dims"("public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_dims"("public"."vector")
  RETURNS "pg_catalog"."int4" AS '$libdir/vector', 'vector_dims'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_dims"("public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_eq
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_eq"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_eq"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."bool" AS '$libdir/vector', 'vector_eq'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_eq"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_ge
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_ge"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_ge"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."bool" AS '$libdir/vector', 'vector_ge'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_ge"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_gt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_gt"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_gt"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."bool" AS '$libdir/vector', 'vector_gt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_gt"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_in
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_in"(cstring, oid, int4);
CREATE OR REPLACE FUNCTION "public"."vector_in"(cstring, oid, int4)
  RETURNS "public"."vector" AS '$libdir/vector', 'vector_in'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_in"(cstring, oid, int4) OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_l2_squared_distance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_l2_squared_distance"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_l2_squared_distance"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."float8" AS '$libdir/vector', 'vector_l2_squared_distance'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_l2_squared_distance"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_le
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_le"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_le"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."bool" AS '$libdir/vector', 'vector_le'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_le"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_lt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_lt"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_lt"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."bool" AS '$libdir/vector', 'vector_lt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_lt"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_ne
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_ne"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_ne"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."bool" AS '$libdir/vector', 'vector_ne'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_ne"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_negative_inner_product
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_negative_inner_product"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_negative_inner_product"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."float8" AS '$libdir/vector', 'vector_negative_inner_product'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_negative_inner_product"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_norm
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_norm"("public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_norm"("public"."vector")
  RETURNS "pg_catalog"."float8" AS '$libdir/vector', 'vector_norm'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_norm"("public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_out
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_out"("public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_out"("public"."vector")
  RETURNS "pg_catalog"."cstring" AS '$libdir/vector', 'vector_out'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_out"("public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_recv
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_recv"(internal, oid, int4);
CREATE OR REPLACE FUNCTION "public"."vector_recv"(internal, oid, int4)
  RETURNS "public"."vector" AS '$libdir/vector', 'vector_recv'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_recv"(internal, oid, int4) OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_send
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_send"("public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_send"("public"."vector")
  RETURNS "pg_catalog"."bytea" AS '$libdir/vector', 'vector_send'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_send"("public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_spherical_distance
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_spherical_distance"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_spherical_distance"("public"."vector", "public"."vector")
  RETURNS "pg_catalog"."float8" AS '$libdir/vector', 'vector_spherical_distance'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_spherical_distance"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_sub
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_sub"("public"."vector", "public"."vector");
CREATE OR REPLACE FUNCTION "public"."vector_sub"("public"."vector", "public"."vector")
  RETURNS "public"."vector" AS '$libdir/vector', 'vector_sub'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_sub"("public"."vector", "public"."vector") OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_to_float4
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_to_float4"("public"."vector", int4, bool);
CREATE OR REPLACE FUNCTION "public"."vector_to_float4"("public"."vector", int4, bool)
  RETURNS "pg_catalog"."_float4" AS '$libdir/vector', 'vector_to_float4'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_to_float4"("public"."vector", int4, bool) OWNER TO "postgres";

-- ----------------------------
-- Function structure for vector_typmod_in
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."vector_typmod_in"(_cstring);
CREATE OR REPLACE FUNCTION "public"."vector_typmod_in"(_cstring)
  RETURNS "pg_catalog"."int4" AS '$libdir/vector', 'vector_typmod_in'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."vector_typmod_in"(_cstring) OWNER TO "postgres";

-- ----------------------------
-- Indexes structure for table asset_classification_feedback
-- ----------------------------
CREATE INDEX "idx_asset_classification_feedback_asset_id" ON "public"."asset_classification_feedback" USING btree (
  "asset_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);
CREATE INDEX "idx_asset_classification_feedback_user_id" ON "public"."asset_classification_feedback" USING btree (
  "user_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table asset_classification_feedback
-- ----------------------------
ALTER TABLE "public"."asset_classification_feedback" ADD CONSTRAINT "asset_classification_feedback_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table asset_media
-- ----------------------------
CREATE INDEX "idx_asset_media_ai_meta_gin" ON "public"."asset_media" USING gin (
  "ai_meta" "pg_catalog"."jsonb_ops"
);
CREATE INDEX "idx_asset_media_asset_id" ON "public"."asset_media" USING btree (
  "asset_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);
CREATE INDEX "idx_asset_media_media_type" ON "public"."asset_media" USING btree (
  "media_type" "pg_catalog"."enum_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table asset_media
-- ----------------------------
ALTER TABLE "public"."asset_media" ADD CONSTRAINT "asset_media_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table asset_object_detections
-- ----------------------------
CREATE INDEX "idx_asset_object_detections_asset_id" ON "public"."asset_object_detections" USING btree (
  "asset_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);
CREATE INDEX "idx_asset_object_detections_media_id" ON "public"."asset_object_detections" USING btree (
  "media_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);
CREATE INDEX "idx_asset_object_detections_object_name" ON "public"."asset_object_detections" USING btree (
  "object_name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Checks structure for table asset_object_detections
-- ----------------------------
ALTER TABLE "public"."asset_object_detections" ADD CONSTRAINT "detection_box_range" CHECK (box_x >= 0::numeric AND box_x <= 1::numeric AND box_y >= 0::numeric AND box_y <= 1::numeric AND box_w > 0::numeric AND box_w <= 1::numeric AND box_h > 0::numeric AND box_h <= 1::numeric);

-- ----------------------------
-- Primary Key structure for table asset_object_detections
-- ----------------------------
ALTER TABLE "public"."asset_object_detections" ADD CONSTRAINT "asset_object_detections_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table asset_tags
-- ----------------------------
CREATE INDEX "idx_asset_tags_asset_id" ON "public"."asset_tags" USING btree (
  "asset_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);
CREATE INDEX "idx_asset_tags_tag_id" ON "public"."asset_tags" USING btree (
  "tag_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);

-- ----------------------------
-- Uniques structure for table asset_tags
-- ----------------------------
ALTER TABLE "public"."asset_tags" ADD CONSTRAINT "asset_tags_asset_id_tag_id_key" UNIQUE ("asset_id", "tag_id");

-- ----------------------------
-- Primary Key structure for table asset_tags
-- ----------------------------
ALTER TABLE "public"."asset_tags" ADD CONSTRAINT "asset_tags_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table assets
-- ----------------------------
CREATE INDEX "idx_assets_event_time_start" ON "public"."assets" USING btree (
  "event_time_start" "pg_catalog"."timestamptz_ops" ASC NULLS LAST
);
CREATE INDEX "idx_assets_location_name" ON "public"."assets" USING btree (
  "location_name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_assets_metadata_gin" ON "public"."assets" USING gin (
  "metadata" "pg_catalog"."jsonb_ops"
);
CREATE INDEX "idx_assets_text_search" ON "public"."assets" USING gin (
  to_tsvector('simple'::regconfig, (((COALESCE(title, ''::character varying)::text || ' '::text) || COALESCE(summary, ''::text)) || ' '::text) || COALESCE(content_text, ''::text)) "pg_catalog"."tsvector_ops"
);
CREATE INDEX "idx_assets_user_status" ON "public"."assets" USING btree (
  "user_id" "pg_catalog"."uuid_ops" ASC NULLS LAST,
  "status" "pg_catalog"."enum_ops" ASC NULLS LAST
);
CREATE INDEX "idx_assets_user_type_captured" ON "public"."assets" USING btree (
  "user_id" "pg_catalog"."uuid_ops" ASC NULLS LAST,
  "asset_type" "pg_catalog"."enum_ops" ASC NULLS LAST,
  "captured_at" "pg_catalog"."timestamptz_ops" DESC NULLS FIRST
);

-- ----------------------------
-- Triggers structure for table assets
-- ----------------------------
CREATE TRIGGER "trg_assets_updated_at" BEFORE UPDATE ON "public"."assets"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_updated_at"();

-- ----------------------------
-- Checks structure for table assets
-- ----------------------------
ALTER TABLE "public"."assets" ADD CONSTRAINT "assets_lat_lng_check" CHECK (latitude IS NULL AND longitude IS NULL OR latitude >= '-90'::integer::numeric AND latitude <= 90::numeric AND longitude >= '-180'::integer::numeric AND longitude <= 180::numeric);

-- ----------------------------
-- Primary Key structure for table assets
-- ----------------------------
ALTER TABLE "public"."assets" ADD CONSTRAINT "assets_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table llm_call_logs
-- ----------------------------
CREATE INDEX "idx_llm_call_logs_asset_id" ON "public"."llm_call_logs" USING btree (
  "asset_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);
CREATE INDEX "idx_llm_call_logs_created_at" ON "public"."llm_call_logs" USING btree (
  "created_at" "pg_catalog"."timestamptz_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_llm_call_logs_user_id" ON "public"."llm_call_logs" USING btree (
  "user_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table llm_call_logs
-- ----------------------------
ALTER TABLE "public"."llm_call_logs" ADD CONSTRAINT "llm_call_logs_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table tags
-- ----------------------------
CREATE INDEX "idx_tags_category" ON "public"."tags" USING btree (
  "category" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_tags_owner_category_sort" ON "public"."tags" USING btree (
  "owner_user_id" "pg_catalog"."uuid_ops" ASC NULLS LAST,
  "category" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "hit_count" "pg_catalog"."int8_ops" DESC NULLS FIRST,
  "last_used_at" "pg_catalog"."timestamptz_ops" DESC NULLS FIRST,
  "created_at" "pg_catalog"."timestamptz_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_tags_parent_id" ON "public"."tags" USING btree (
  "parent_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);

-- ----------------------------
-- Triggers structure for table tags
-- ----------------------------
CREATE TRIGGER "trg_tags_updated_at" BEFORE UPDATE ON "public"."tags"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_updated_at"();

-- ----------------------------
-- Uniques structure for table tags
-- ----------------------------
ALTER TABLE "public"."tags" ADD CONSTRAINT "tags_owner_user_id_slug_key" UNIQUE ("owner_user_id", "slug");

-- ----------------------------
-- Primary Key structure for table tags
-- ----------------------------
ALTER TABLE "public"."tags" ADD CONSTRAINT "tags_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table user_auth_accounts
-- ----------------------------
CREATE INDEX "idx_user_auth_accounts_user_id" ON "public"."user_auth_accounts" USING btree (
  "user_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);

-- ----------------------------
-- Triggers structure for table user_auth_accounts
-- ----------------------------
CREATE TRIGGER "trg_user_auth_accounts_updated_at" BEFORE UPDATE ON "public"."user_auth_accounts"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_updated_at"();

-- ----------------------------
-- Uniques structure for table user_auth_accounts
-- ----------------------------
ALTER TABLE "public"."user_auth_accounts" ADD CONSTRAINT "user_auth_accounts_provider_provider_user_id_key" UNIQUE ("provider", "provider_user_id");

-- ----------------------------
-- Primary Key structure for table user_auth_accounts
-- ----------------------------
ALTER TABLE "public"."user_auth_accounts" ADD CONSTRAINT "user_auth_accounts_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table user_sessions
-- ----------------------------
CREATE INDEX "idx_user_sessions_expires_at" ON "public"."user_sessions" USING btree (
  "expires_at" "pg_catalog"."timestamptz_ops" ASC NULLS LAST
);
CREATE INDEX "idx_user_sessions_user_id" ON "public"."user_sessions" USING btree (
  "user_id" "pg_catalog"."uuid_ops" ASC NULLS LAST
);

-- ----------------------------
-- Uniques structure for table user_sessions
-- ----------------------------
ALTER TABLE "public"."user_sessions" ADD CONSTRAINT "user_sessions_token_key" UNIQUE ("token");

-- ----------------------------
-- Primary Key structure for table user_sessions
-- ----------------------------
ALTER TABLE "public"."user_sessions" ADD CONSTRAINT "user_sessions_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Triggers structure for table user_sync_settings
-- ----------------------------
CREATE TRIGGER "trg_user_sync_settings_updated_at" BEFORE UPDATE ON "public"."user_sync_settings"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_updated_at"();

-- ----------------------------
-- Uniques structure for table user_sync_settings
-- ----------------------------
ALTER TABLE "public"."user_sync_settings" ADD CONSTRAINT "user_sync_settings_user_id_key" UNIQUE ("user_id");

-- ----------------------------
-- Primary Key structure for table user_sync_settings
-- ----------------------------
ALTER TABLE "public"."user_sync_settings" ADD CONSTRAINT "user_sync_settings_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Triggers structure for table users
-- ----------------------------
CREATE TRIGGER "trg_users_updated_at" BEFORE UPDATE ON "public"."users"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_updated_at"();

-- ----------------------------
-- Primary Key structure for table users
-- ----------------------------
ALTER TABLE "public"."users" ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Keys structure for table asset_classification_feedback
-- ----------------------------
ALTER TABLE "public"."asset_classification_feedback" ADD CONSTRAINT "asset_classification_feedback_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "public"."assets" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."asset_classification_feedback" ADD CONSTRAINT "asset_classification_feedback_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table asset_media
-- ----------------------------
ALTER TABLE "public"."asset_media" ADD CONSTRAINT "asset_media_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "public"."assets" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table asset_object_detections
-- ----------------------------
ALTER TABLE "public"."asset_object_detections" ADD CONSTRAINT "asset_object_detections_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "public"."assets" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."asset_object_detections" ADD CONSTRAINT "asset_object_detections_media_id_fkey" FOREIGN KEY ("media_id") REFERENCES "public"."asset_media" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table asset_tags
-- ----------------------------
ALTER TABLE "public"."asset_tags" ADD CONSTRAINT "asset_tags_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "public"."assets" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."asset_tags" ADD CONSTRAINT "asset_tags_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "public"."tags" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table assets
-- ----------------------------
ALTER TABLE "public"."assets" ADD CONSTRAINT "assets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table llm_call_logs
-- ----------------------------
ALTER TABLE "public"."llm_call_logs" ADD CONSTRAINT "llm_call_logs_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "public"."assets" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "public"."llm_call_logs" ADD CONSTRAINT "llm_call_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table tags
-- ----------------------------
ALTER TABLE "public"."tags" ADD CONSTRAINT "tags_owner_user_id_fkey" FOREIGN KEY ("owner_user_id") REFERENCES "public"."users" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "public"."tags" ADD CONSTRAINT "tags_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."tags" ("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table user_auth_accounts
-- ----------------------------
ALTER TABLE "public"."user_auth_accounts" ADD CONSTRAINT "user_auth_accounts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table user_sessions
-- ----------------------------
ALTER TABLE "public"."user_sessions" ADD CONSTRAINT "user_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table user_sync_settings
-- ----------------------------
ALTER TABLE "public"."user_sync_settings" ADD CONSTRAINT "user_sync_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;
