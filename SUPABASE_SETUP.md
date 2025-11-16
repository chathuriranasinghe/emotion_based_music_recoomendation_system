# Supabase Setup Instructions

## 1. Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Sign up/Login and create a new project
3. Wait for the project to be ready

## 2. Get Project Credentials
1. Go to Project Settings > API
2. Copy the Project URL and anon/public key
3. Update `lib/config/supabase_config.dart` with your credentials:
   ```dart
   class SupabaseConfig {
     static const String url = 'YOUR_PROJECT_URL_HERE';
     static const String anonKey = 'YOUR_ANON_KEY_HERE';
   }
   ```

## 3. Create Database Tables
1. Go to SQL Editor in your Supabase dashboard
2. Copy and paste the contents of `database/create_tables.sql`
3. Run the SQL script to create all tables and policies

## 4. Install Dependencies
Run the following command in your project directory:
```bash
flutter pub get
```

## 5. Test Registration
1. Run your Flutter app
2. Try registering a new user
3. Check the Supabase dashboard to see if the user was created in both:
   - Authentication > Users
   - Table Editor > users table

## Database Schema

### users table
- `id`: UUID (references auth.users)
- `email`: TEXT (unique)
- `username`: TEXT (unique)
- `age`: INTEGER
- `created_at`: TIMESTAMP
- `updated_at`: TIMESTAMP

### user_emotions table
- `id`: UUID (primary key)
- `user_id`: UUID (foreign key to users)
- `emotion`: TEXT
- `confidence`: DECIMAL
- `eeg_data`: JSONB
- `created_at`: TIMESTAMP

### user_music_preferences table
- `id`: UUID (primary key)
- `user_id`: UUID (foreign key to users)
- `emotion`: TEXT
- `spotify_track_id`: TEXT
- `track_name`: TEXT
- `artist_name`: TEXT
- `liked`: BOOLEAN
- `created_at`: TIMESTAMP

## Security
- Row Level Security (RLS) is enabled on all tables
- Users can only access their own data
- Policies ensure data privacy and security