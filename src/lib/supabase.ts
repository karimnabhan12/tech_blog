import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface Author {
  id: string;
  name: string;
  bio: string;
  avatar_url: string;
  twitter_handle: string | null;
  created_at: string;
}

export interface BlogPost {
  id: string;
  title: string;
  slug: string;
  excerpt: string;
  content: string;
  cover_image_url: string;
  author_id: string;
  category: string;
  tags: string[];
  read_time_minutes: number;
  published: boolean;
  published_at: string | null;
  created_at: string;
  updated_at: string;
  author?: Author;
}

export async function getAllBlogPosts() {
  const { data, error } = await supabase
    .from('blog_posts')
    .select(`
      *,
      author:authors(*)
    `)
    .eq('published', true)
    .order('published_at', { ascending: false });

  if (error) throw error;
  return data as (BlogPost & { author: Author })[];
}

export async function getBlogPostBySlug(slug: string) {
  const { data, error } = await supabase
    .from('blog_posts')
    .select(`
      *,
      author:authors(*)
    `)
    .eq('slug', slug)
    .eq('published', true)
    .maybeSingle();

  if (error) throw error;
  return data as (BlogPost & { author: Author }) | null;
}

export async function getBlogPostsByCategory(category: string) {
  const { data, error } = await supabase
    .from('blog_posts')
    .select(`
      *,
      author:authors(*)
    `)
    .eq('category', category)
    .eq('published', true)
    .order('published_at', { ascending: false });

  if (error) throw error;
  return data as (BlogPost & { author: Author })[];
}
