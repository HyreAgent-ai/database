


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";





SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."applications" (
    "id" "text" NOT NULL,
    "role" "text",
    "company" "text",
    "location" "text",
    "link" "text",
    "company_link" "text",
    "match" integer,
    "verdict" "text",
    "status" "text",
    "date" "text",
    "location_type" "text",
    "type" "text",
    "salary" "text",
    "resume_variant" "text",
    "fit_level" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "user_id" "uuid"
);


ALTER TABLE "public"."applications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."company_intelligence" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "domain" "text",
    "tier" integer,
    "h1b" "text",
    "itar" "text",
    "industry" "text",
    "roles" "text",
    "ats_platform" "text",
    "ats_board_url" "text",
    "added_by" "uuid",
    "contributed_by_users" "uuid"[] DEFAULT '{}'::"uuid"[]
);


ALTER TABLE "public"."company_intelligence" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."contacts" (
    "id" "text" NOT NULL,
    "name" "text",
    "company" "text",
    "position" "text",
    "role_type" "text",
    "conv_status" "text",
    "last_contact" "text",
    "days_since" integer,
    "message_count" integer,
    "follow_up" boolean DEFAULT false,
    "priority" integer,
    "next_action" "text",
    "summary" "text",
    "notes" "text",
    "linkedin_url" "text",
    "email" "text",
    "source" "text" DEFAULT 'linkedin_dm'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "user_id" "uuid",
    "persona" "text",
    "persona_confidence" integer,
    "conversation_stage" "text",
    "relationship_strength" "text",
    "i_sent_first" boolean,
    "they_replied" boolean,
    "two_way_conversation" boolean,
    "total_exchanges" integer,
    "tone" "text",
    "referral_discussed" boolean,
    "referral_secured" boolean,
    "hiring_process_related" boolean,
    "promise_made" boolean,
    "promise_text" "text",
    "promise_status" "text",
    "poc_score" integer,
    "is_poc_candidate" boolean DEFAULT false,
    "is_confirmed_poc" boolean DEFAULT false,
    "follow_up_priority" "text",
    "follow_up_type" "text",
    "follow_up_reason" "text",
    "follow_up_timing" "text",
    "follow_up_guidance" "text",
    "crm_summary" "text",
    "risk_notes" "text",
    "tags" "text",
    "first_message_preview" "text",
    "last_message_preview" "text",
    "outreach_sent" boolean DEFAULT false,
    "outreach_date" "date",
    "outreach_status" "text",
    "outreach_status_changed_at" timestamp with time zone,
    "follow_up_snoozed_until" "date"
);


ALTER TABLE "public"."contacts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."job_analysis_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "job_id" "text",
    "variant_used" "text",
    "analysis_result" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."job_analysis_history" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."jobs" (
    "id" "text" NOT NULL,
    "role" "text",
    "company" "text",
    "location" "text",
    "type" "text",
    "link" "text",
    "posted" "text",
    "itar_flag" boolean DEFAULT false,
    "itar_detail" "text",
    "tier" "text",
    "h1b" "text",
    "industry" "text",
    "reason" "text",
    "match" integer,
    "verdict" "text",
    "source" "text",
    "jd" "text",
    "analysis_result" "jsonb",
    "location_type" "text",
    "salary" "text",
    "resume_variant" "text",
    "in_pipeline" boolean DEFAULT false,
    "pipeline_added_at" timestamp with time zone,
    "status" "text" DEFAULT 'active'::"text",
    "addedAt" bigint,
    "domain_verified" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."jobs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."normalized_jobs" (
    "id" "text" NOT NULL,
    "job_title" "text",
    "company_name" "text",
    "job_url" "text",
    "location" "text",
    "posted_date" "text",
    "description" "text",
    "source" "text",
    "itar_flag" boolean DEFAULT false,
    "tier" "text",
    "h1b" "text",
    "industry" "text",
    "verdict" "text" DEFAULT 'GREEN'::"text",
    "relevance_score" integer DEFAULT 50,
    "boost_tags" "text"[] DEFAULT '{}'::"text"[],
    "pipeline_run_date" "date",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "red_flags" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "legitimacy_tier" "text" DEFAULT 'high'::"text" NOT NULL,
    "employment_type" "text" DEFAULT ''::"text" NOT NULL
);


ALTER TABLE "public"."normalized_jobs" OWNER TO "postgres";


COMMENT ON COLUMN "public"."normalized_jobs"."red_flags" IS 'Array of legitimacy flags: staffing_agency, us_person_required, vague_description, contract_hidden';



COMMENT ON COLUMN "public"."normalized_jobs"."legitimacy_tier" IS 'Pipeline legitimacy assessment: high (clean), caution (minor flags), suspicious (critical flags)';



COMMENT ON COLUMN "public"."normalized_jobs"."employment_type" IS 'Employment type sourced from scraper. "Contract" = contract/temp role from contract_scraper.py. Empty = FTE or unspecified.';



CREATE TABLE IF NOT EXISTS "public"."resume_variants" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "variant_key" "text" NOT NULL,
    "variant_name" "text" NOT NULL,
    "summary_template" "text",
    "skill_lines" "jsonb" DEFAULT '[]'::"jsonb",
    "keywords_primary" "text"[] DEFAULT '{}'::"text"[],
    "keywords_secondary" "text"[] DEFAULT '{}'::"text"[],
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."resume_variants" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."resumes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" "text" DEFAULT 'My Resume'::"text" NOT NULL,
    "is_primary" boolean DEFAULT false,
    "target_roles" "text"[] DEFAULT '{}'::"text"[],
    "structured_sections" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "analysis_report" "jsonb",
    "last_analyzed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."resumes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."role_targets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "cluster" "text" NOT NULL,
    "priority" integer DEFAULT 1,
    "active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "keywords" "text"[] DEFAULT '{}'::"text"[],
    "boost_tags" "text"[] DEFAULT '{}'::"text"[],
    "require_h1b" boolean DEFAULT false
);


ALTER TABLE "public"."role_targets" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."scraper_runs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "run_date" "date" NOT NULL,
    "scraper" "text" NOT NULL,
    "status" "text",
    "jobs_found" integer DEFAULT 0,
    "error_message" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."scraper_runs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."settings" (
    "key" "text" NOT NULL,
    "value" "text"
);


ALTER TABLE "public"."settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."templates" (
    "id" "text" NOT NULL,
    "name" "text",
    "body" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "user_id" "uuid"
);


ALTER TABLE "public"."templates" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_company_targets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "company_id" "uuid" NOT NULL,
    "is_primary" boolean DEFAULT false,
    "priority" integer DEFAULT 1,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_company_targets" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_integrations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "service" "text" NOT NULL,
    "api_key" "text",
    "is_valid" boolean,
    "last_validated_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_integrations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_job_feed" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "job_id" "text",
    "user_relevance_score" integer DEFAULT 0,
    "matched_clusters" "text"[] DEFAULT '{}'::"text"[],
    "status" "text" DEFAULT 'new'::"text",
    "in_pipeline" boolean DEFAULT false,
    "pipeline_added_at" timestamp with time zone,
    "analysis_result" "jsonb",
    "resume_variant" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "score_breakdown" "jsonb"
);


ALTER TABLE "public"."user_job_feed" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user_job_feed"."score_breakdown" IS '6-dimensional score breakdown: {title_match, h1b_score, itar_clean, entry_level, company_intel, legitimacy}';



CREATE TABLE IF NOT EXISTS "public"."user_preferences" (
    "user_id" "uuid" NOT NULL,
    "theme" "text" DEFAULT 'dark'::"text",
    "feed_min_score" integer DEFAULT 30,
    "h1b_filter" boolean DEFAULT false,
    "itar_strict" boolean DEFAULT true,
    "location_preference" "text"[] DEFAULT '{}'::"text"[],
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_preferences" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "full_name" "text",
    "degree" "text",
    "graduation_year" integer,
    "visa_status" "text",
    "visa_years_remaining" integer,
    "sponsorship_required" boolean DEFAULT false,
    "experience_bullets" "jsonb" DEFAULT '[]'::"jsonb",
    "tool_list" "text"[] DEFAULT '{}'::"text"[],
    "domain_family" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "linkedin_url" "text"
);


ALTER TABLE "public"."user_profiles" OWNER TO "postgres";


ALTER TABLE ONLY "public"."applications"
    ADD CONSTRAINT "applications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."company_intelligence"
    ADD CONSTRAINT "company_intelligence_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."job_analysis_history"
    ADD CONSTRAINT "job_analysis_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "linkedin_dm_contacts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."normalized_jobs"
    ADD CONSTRAINT "normalized_jobs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."resume_variants"
    ADD CONSTRAINT "resume_variants_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."resume_variants"
    ADD CONSTRAINT "resume_variants_user_id_variant_key_key" UNIQUE ("user_id", "variant_key");



ALTER TABLE ONLY "public"."resumes"
    ADD CONSTRAINT "resumes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."role_targets"
    ADD CONSTRAINT "role_targets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."scraper_runs"
    ADD CONSTRAINT "scraper_runs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."settings"
    ADD CONSTRAINT "settings_pkey" PRIMARY KEY ("key");



ALTER TABLE ONLY "public"."templates"
    ADD CONSTRAINT "templates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_company_targets"
    ADD CONSTRAINT "user_company_targets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_company_targets"
    ADD CONSTRAINT "user_company_targets_user_id_company_id_key" UNIQUE ("user_id", "company_id");



ALTER TABLE ONLY "public"."user_integrations"
    ADD CONSTRAINT "user_integrations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_integrations"
    ADD CONSTRAINT "user_integrations_user_id_service_key" UNIQUE ("user_id", "service");



ALTER TABLE ONLY "public"."user_job_feed"
    ADD CONSTRAINT "user_job_feed_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_job_feed"
    ADD CONSTRAINT "user_job_feed_user_id_job_id_key" UNIQUE ("user_id", "job_id");



ALTER TABLE ONLY "public"."user_preferences"
    ADD CONSTRAINT "user_preferences_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_user_id_key" UNIQUE ("user_id");



CREATE INDEX "idx_ldm_conversation_stage" ON "public"."contacts" USING "btree" ("conversation_stage");



CREATE INDEX "idx_ldm_follow_up_priority" ON "public"."contacts" USING "btree" ("follow_up_priority");



CREATE INDEX "idx_ldm_persona" ON "public"."contacts" USING "btree" ("persona");



CREATE INDEX "idx_ldm_poc_candidate" ON "public"."contacts" USING "btree" ("is_poc_candidate");



CREATE INDEX "idx_ldm_relationship" ON "public"."contacts" USING "btree" ("relationship_strength");



CREATE INDEX "idx_normalized_jobs_employment_type" ON "public"."normalized_jobs" USING "btree" ("employment_type") WHERE ("employment_type" <> ''::"text");



CREATE INDEX "idx_normalized_jobs_legitimacy_tier" ON "public"."normalized_jobs" USING "btree" ("legitimacy_tier") WHERE ("legitimacy_tier" <> 'high'::"text");



CREATE INDEX "resumes_user_id_idx" ON "public"."resumes" USING "btree" ("user_id");



ALTER TABLE ONLY "public"."applications"
    ADD CONSTRAINT "applications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."company_intelligence"
    ADD CONSTRAINT "company_intelligence_added_by_fkey" FOREIGN KEY ("added_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."job_analysis_history"
    ADD CONSTRAINT "job_analysis_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "linkedin_dm_contacts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."resume_variants"
    ADD CONSTRAINT "resume_variants_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."resumes"
    ADD CONSTRAINT "resumes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."role_targets"
    ADD CONSTRAINT "role_targets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."templates"
    ADD CONSTRAINT "templates_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."user_company_targets"
    ADD CONSTRAINT "user_company_targets_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."company_intelligence"("id");



ALTER TABLE ONLY "public"."user_company_targets"
    ADD CONSTRAINT "user_company_targets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."user_integrations"
    ADD CONSTRAINT "user_integrations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."user_job_feed"
    ADD CONSTRAINT "user_job_feed_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."normalized_jobs"("id");



ALTER TABLE ONLY "public"."user_job_feed"
    ADD CONSTRAINT "user_job_feed_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."user_preferences"
    ADD CONSTRAINT "user_preferences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE "public"."applications" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "authenticated_read_companies" ON "public"."company_intelligence" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_jobs" ON "public"."jobs" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_normalized_jobs" ON "public"."normalized_jobs" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_scraper_runs" ON "public"."scraper_runs" FOR SELECT TO "authenticated" USING (true);



ALTER TABLE "public"."company_intelligence" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."contacts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."job_analysis_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."jobs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."normalized_jobs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "preferences_user_owns" ON "public"."user_preferences" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



ALTER TABLE "public"."resume_variants" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."resumes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "resumes_user_owns" ON "public"."resumes" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



ALTER TABLE "public"."role_targets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."scraper_runs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."templates" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_can_add_companies" ON "public"."company_intelligence" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "added_by"));



CREATE POLICY "user_can_edit_own_companies" ON "public"."company_intelligence" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "added_by")) WITH CHECK (("auth"."uid"() = "added_by"));



ALTER TABLE "public"."user_company_targets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_integrations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_job_feed" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_owns_analysis_history" ON "public"."job_analysis_history" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "user_owns_applications" ON "public"."applications" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "user_owns_company_targets" ON "public"."user_company_targets" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "user_owns_contacts" ON "public"."contacts" TO "authenticated" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "user_owns_feed" ON "public"."user_job_feed" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "user_owns_integrations" ON "public"."user_integrations" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "user_owns_preferences" ON "public"."user_preferences" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "user_owns_profile" ON "public"."user_profiles" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "user_owns_resume_variants" ON "public"."resume_variants" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "user_owns_role_targets" ON "public"."role_targets" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "user_owns_templates" ON "public"."templates" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."user_preferences" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_profiles" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";





































































































































































GRANT ALL ON TABLE "public"."applications" TO "anon";
GRANT ALL ON TABLE "public"."applications" TO "authenticated";
GRANT ALL ON TABLE "public"."applications" TO "service_role";



GRANT ALL ON TABLE "public"."company_intelligence" TO "anon";
GRANT ALL ON TABLE "public"."company_intelligence" TO "authenticated";
GRANT ALL ON TABLE "public"."company_intelligence" TO "service_role";



GRANT ALL ON TABLE "public"."contacts" TO "anon";
GRANT ALL ON TABLE "public"."contacts" TO "authenticated";
GRANT ALL ON TABLE "public"."contacts" TO "service_role";



GRANT ALL ON TABLE "public"."job_analysis_history" TO "anon";
GRANT ALL ON TABLE "public"."job_analysis_history" TO "authenticated";
GRANT ALL ON TABLE "public"."job_analysis_history" TO "service_role";



GRANT ALL ON TABLE "public"."jobs" TO "anon";
GRANT ALL ON TABLE "public"."jobs" TO "authenticated";
GRANT ALL ON TABLE "public"."jobs" TO "service_role";



GRANT ALL ON TABLE "public"."normalized_jobs" TO "anon";
GRANT ALL ON TABLE "public"."normalized_jobs" TO "authenticated";
GRANT ALL ON TABLE "public"."normalized_jobs" TO "service_role";



GRANT ALL ON TABLE "public"."resume_variants" TO "anon";
GRANT ALL ON TABLE "public"."resume_variants" TO "authenticated";
GRANT ALL ON TABLE "public"."resume_variants" TO "service_role";



GRANT ALL ON TABLE "public"."resumes" TO "anon";
GRANT ALL ON TABLE "public"."resumes" TO "authenticated";
GRANT ALL ON TABLE "public"."resumes" TO "service_role";



GRANT ALL ON TABLE "public"."role_targets" TO "anon";
GRANT ALL ON TABLE "public"."role_targets" TO "authenticated";
GRANT ALL ON TABLE "public"."role_targets" TO "service_role";



GRANT ALL ON TABLE "public"."scraper_runs" TO "anon";
GRANT ALL ON TABLE "public"."scraper_runs" TO "authenticated";
GRANT ALL ON TABLE "public"."scraper_runs" TO "service_role";



GRANT ALL ON TABLE "public"."settings" TO "anon";
GRANT ALL ON TABLE "public"."settings" TO "authenticated";
GRANT ALL ON TABLE "public"."settings" TO "service_role";



GRANT ALL ON TABLE "public"."templates" TO "anon";
GRANT ALL ON TABLE "public"."templates" TO "authenticated";
GRANT ALL ON TABLE "public"."templates" TO "service_role";



GRANT ALL ON TABLE "public"."user_company_targets" TO "anon";
GRANT ALL ON TABLE "public"."user_company_targets" TO "authenticated";
GRANT ALL ON TABLE "public"."user_company_targets" TO "service_role";



GRANT ALL ON TABLE "public"."user_integrations" TO "anon";
GRANT ALL ON TABLE "public"."user_integrations" TO "authenticated";
GRANT ALL ON TABLE "public"."user_integrations" TO "service_role";



GRANT ALL ON TABLE "public"."user_job_feed" TO "anon";
GRANT ALL ON TABLE "public"."user_job_feed" TO "authenticated";
GRANT ALL ON TABLE "public"."user_job_feed" TO "service_role";



GRANT ALL ON TABLE "public"."user_preferences" TO "anon";
GRANT ALL ON TABLE "public"."user_preferences" TO "authenticated";
GRANT ALL ON TABLE "public"."user_preferences" TO "service_role";



GRANT ALL ON TABLE "public"."user_profiles" TO "anon";
GRANT ALL ON TABLE "public"."user_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_profiles" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































