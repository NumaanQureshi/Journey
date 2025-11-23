CREATE TABLE public.profiles (
  user_id integer NOT NULL,
  name character varying,
  age integer,
  gender character varying,
  height_in numeric,
  weight_lb numeric,
  main_focus character varying,
  goal_weight_lb numeric,
  activity_intensity character varying,
  CONSTRAINT profiles_pkey PRIMARY KEY (user_id),
  CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);
CREATE TABLE public.users (
  id integer NOT NULL DEFAULT nextval('users_id_seq'::regclass),
  email character varying NOT NULL UNIQUE,
  password_hash character varying NOT NULL,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);
CREATE TABLE public.friends (
    user_id_1 integer NOT NULL,
    user_id_2 integer NOT NULL,
    CONSTRAINT user_friends_pk PRIMARY KEY (user_id_1, user_id_2),
    CONSTRAINT fk_user_1 FOREIGN KEY (user_id_1) REFERENCES public.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_2 FOREIGN KEY (user_id_2) REFERENCES public.users(id) ON DELETE CASCADE,
    CONSTRAINT check_ids_order CHECK (user_id_1 < user_id_2)
);
CREATE TABLE public.friend_requests (
    sender_id integer NOT NULL,
    receiver_id integer NOT NULL,
    status character varying DEFAULT 'pending' NOT NULL, -- 'pending', 'accepted', 'rejected'
    sent_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT friend_requests_pk PRIMARY KEY (sender_id, receiver_id),
    CONSTRAINT fk_sender FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_receiver FOREIGN KEY (receiver_id) REFERENCES public.users(id) ON DELETE CASCADE
);
CREATE TABLE public.exercises (
    id integer NOT NULL PRIMARY KEY,
    name character varying NOT NULL UNIQUE,
    description text,
    category character varying
);
CREATE TABLE public.plans (
    id integer NOT NULL PRIMARY KEY,
    user_id integer,
    name character varying NOT NULL,
    is_public boolean DEFAULT FALSE,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_plan_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL
);
CREATE TABLE public.workouts (
    id integer NOT NULL PRIMARY KEY,
    user_id integer NOT NULL,
    plan_id integer, -- plan link
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    duration_min numeric,
    calories_burned integer,
    total_points_earned integer DEFAULT 0,
    CONSTRAINT fk_workout_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_plan FOREIGN KEY (plan_id) REFERENCES public.plans(id) ON DELETE SET NULL
);
CREATE TABLE public.leaderboard (
  user_id integer NOT NULL,
  total_points integer DEFAULT 0,
  workouts_completed integer DEFAULT 0,
  challenges_completed integer DEFAULT 0,
  current_streak_days integer DEFAULT 0,
  longest_streak_days integer DEFAULT 0,
  total_calories_burned integer DEFAULT 0,
  rank integer,
  last_updated timestamp without time zone DEFAULT now(),
  CONSTRAINT leaderboard_pkey PRIMARY KEY (user_id),
  CONSTRAINT leaderboard_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);