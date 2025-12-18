create table public.users (
  id serial not null,
  email character varying(100) not null,
  password_hash character varying(255) not null,
  username character varying(50) NOT NULL,
  created_at timestamp without time zone null default CURRENT_TIMESTAMP,
  updated_at timestamp without time zone null default CURRENT_TIMESTAMP,
  constraint users_pkey primary key (id),
  constraint users_email_key unique (email),
  constraint users_username_key unique (username)
) TABLESPACE pg_default;

create table public.profiles (
  user_id integer not null,
  name character varying(255) null,
  age integer null,
  gender character varying(50) null,
  height_in numeric null,
  weight_lb numeric null,
  main_focus character varying(50) null,
  goal_weight_lb numeric null,
  activity_intensity character varying(50) null,
  constraint profiles_pkey primary key (user_id),
  constraint profiles_user_id_fkey foreign KEY (user_id) references users (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.friends (
  user_id_1 integer not null,
  user_id_2 integer not null,
  constraint user_friends_pk primary key (user_id_1, user_id_2),
  constraint fk_user_1 foreign KEY (user_id_1) references users (id) on delete CASCADE,
  constraint fk_user_2 foreign KEY (user_id_2) references users (id) on delete CASCADE,
  constraint check_ids_order check ((user_id_1 < user_id_2))
) TABLESPACE pg_default;

create table public.friend_requests (
  sender_id integer not null,
  receiver_id integer not null,
  status character varying not null default 'pending'::character varying,
  sent_at timestamp without time zone null default CURRENT_TIMESTAMP,
  constraint friend_requests_pk primary key (sender_id, receiver_id),
  constraint fk_receiver foreign KEY (receiver_id) references users (id) on delete CASCADE,
  constraint fk_sender foreign KEY (sender_id) references users (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.exercises (
  id integer not null,
  name character varying not null,
  description text null,
  category character varying null,
  constraint exercises_pkey primary key (id),
  constraint exercises_name_key unique (name)
) TABLESPACE pg_default;

-- A. PROGRAMS (The high-level container, e.g., "Summer Shred")
CREATE TABLE public.programs (
  id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id integer NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  is_active boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now()
);

-- B. WORKOUT_TEMPLATES (The routine blueprint, e.g., "Leg Day")
CREATE TABLE public.workout_templates (
  id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  program_id integer NOT NULL REFERENCES public.programs(id) ON DELETE CASCADE,
  name text NOT NULL, 
  day_order integer DEFAULT 1, -- e.g. 1 for Monday, 2 for Tuesday
  notes text,
  created_at timestamp with time zone DEFAULT now()
);

-- C. TEMPLATE_EXERCISES (The recipe for the routine)
CREATE TABLE public.template_exercises (
  id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  template_id integer NOT NULL REFERENCES public.workout_templates(id) ON DELETE CASCADE,
  exercise_id integer NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
  
  target_sets integer DEFAULT 3,
  target_reps text, -- e.g. "8-12"
  target_weight_lb numeric, 
  rest_seconds integer DEFAULT 60,
  order_index integer DEFAULT 0 
);

-- ==========================================
-- 3. CREATE "LOGGING" TABLES
-- ==========================================

-- D. WORKOUT_SESSIONS (The specific instance of going to the gym)
CREATE TABLE public.workout_sessions (
  id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id integer NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  template_id integer REFERENCES public.workout_templates(id) ON DELETE SET NULL, 
  
  start_time timestamp with time zone DEFAULT now(),
  end_time timestamp with time zone,
  status text DEFAULT 'in_progress', -- 'in_progress', 'completed'
  
  duration_min numeric,
  calories_burned integer,
  total_volume_lb numeric,
  notes text
);

-- E. WORKOUT_SETS (The actual work performed)
CREATE TABLE public.workout_sets (
  id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  session_id integer NOT NULL REFERENCES public.workout_sessions(id) ON DELETE CASCADE,
  exercise_id integer NOT NULL REFERENCES public.exercises(id),
  
  set_number integer NOT NULL, -- e.g. 1, 2, 3
  reps_completed integer,
  weight_lb numeric,
  rpe integer, -- Optional: Rate of Perceived Exertion (1-10)
  is_warmup boolean DEFAULT false,
  
  created_at timestamp with time zone DEFAULT now()
);

create table public.challenges (
  id serial not null,
  user_id integer not null,
  challenge_title character varying(255) not null default ''::character varying,
  challenge_type character varying(50) not null default ''::character varying,
  goal numeric not null default 0,
  current_progress numeric not null default 0,
  is_completed boolean not null default false,
  assigned_at timestamp without time zone not null default CURRENT_TIMESTAMP,
  last_updated timestamp without time zone null default CURRENT_TIMESTAMP,
  constraint challenges_pkey primary key (id),
  constraint fk_challenge_user foreign KEY (user_id) references users (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.leaderboard (
  user_id integer not null,
  total_points integer null default 0,
  workouts_completed integer null default 0,
  challenges_completed integer null default 0,
  current_streak_days integer null default 0,
  longest_streak_days integer null default 0,
  total_calories_burned integer null default 0,
  rank integer null,
  last_updated timestamp without time zone null default now(),
  constraint leaderboard_pkey primary key (user_id),
  constraint leaderboard_user_id_fkey foreign KEY (user_id) references users (id) on delete CASCADE
) TABLESPACE pg_default;