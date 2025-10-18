/*
  # Create Blog Schema

  ## Overview
  This migration creates the core database schema for a premium tech blog website.

  ## New Tables
  
  ### `authors`
  - `id` (uuid, primary key) - Unique identifier for each author
  - `name` (text) - Author's full name
  - `bio` (text) - Short biography
  - `avatar_url` (text) - Profile picture URL
  - `twitter_handle` (text, optional) - Twitter username
  - `created_at` (timestamptz) - Record creation timestamp

  ### `blog_posts`
  - `id` (uuid, primary key) - Unique identifier for each post
  - `title` (text) - Article title
  - `slug` (text, unique) - URL-friendly version of title
  - `excerpt` (text) - Short summary for preview cards
  - `content` (text) - Full article content (markdown supported)
  - `cover_image_url` (text) - Featured image URL
  - `author_id` (uuid, foreign key) - Reference to authors table
  - `category` (text) - Article category (e.g., AI, Web Dev, Cloud)
  - `tags` (text array) - Array of topic tags
  - `read_time_minutes` (integer) - Estimated reading time
  - `published` (boolean) - Publication status
  - `published_at` (timestamptz, optional) - Publication date
  - `created_at` (timestamptz) - Record creation timestamp
  - `updated_at` (timestamptz) - Last modification timestamp

  ## Security
  
  ### Row Level Security (RLS)
  - Both tables have RLS enabled
  - Public read access for published content
  - Authors are publicly viewable
  - Future: Can add authenticated policies for content management
  
  ## Indexes
  - Index on `blog_posts.slug` for fast lookups
  - Index on `blog_posts.published` for filtering
  - Index on `blog_posts.category` for category pages
  - Index on `blog_posts.author_id` for author pages
*/

-- Create authors table
CREATE TABLE IF NOT EXISTS authors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  bio text NOT NULL DEFAULT '',
  avatar_url text NOT NULL DEFAULT '',
  twitter_handle text,
  created_at timestamptz DEFAULT now()
);

-- Create blog_posts table
CREATE TABLE IF NOT EXISTS blog_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text UNIQUE NOT NULL,
  excerpt text NOT NULL DEFAULT '',
  content text NOT NULL DEFAULT '',
  cover_image_url text NOT NULL DEFAULT '',
  author_id uuid REFERENCES authors(id) ON DELETE CASCADE,
  category text NOT NULL DEFAULT 'Technology',
  tags text[] DEFAULT '{}',
  read_time_minutes integer DEFAULT 5,
  published boolean DEFAULT false,
  published_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE authors ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for authors (public read access)
CREATE POLICY "Authors are viewable by everyone"
  ON authors FOR SELECT
  USING (true);

-- RLS Policies for blog_posts (public read access for published posts)
CREATE POLICY "Published blog posts are viewable by everyone"
  ON blog_posts FOR SELECT
  USING (published = true);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_blog_posts_slug ON blog_posts(slug);
CREATE INDEX IF NOT EXISTS idx_blog_posts_published ON blog_posts(published);
CREATE INDEX IF NOT EXISTS idx_blog_posts_category ON blog_posts(category);
CREATE INDEX IF NOT EXISTS idx_blog_posts_author_id ON blog_posts(author_id);
CREATE INDEX IF NOT EXISTS idx_blog_posts_published_at ON blog_posts(published_at DESC);

-- Insert sample authors
INSERT INTO authors (name, bio, avatar_url, twitter_handle) VALUES
  ('Sarah Chen', 'Senior AI Engineer specializing in machine learning and neural networks. Former tech lead at leading AI companies.', 'https://images.pexels.com/photos/3756679/pexels-photo-3756679.jpeg?auto=compress&cs=tinysrgb&w=400', 'sarahchen'),
  ('Marcus Rodriguez', 'Full-stack developer and cloud architecture expert. Passionate about scalable systems and DevOps practices.', 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400', 'marcusdev'),
  ('Emily Watson', 'Cybersecurity researcher and ethical hacker. Focused on making the web safer for everyone.', 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400', 'emilysec')
ON CONFLICT DO NOTHING;

-- Insert sample blog posts
INSERT INTO blog_posts (title, slug, excerpt, content, cover_image_url, author_id, category, tags, read_time_minutes, published, published_at) 
SELECT 
  'The Future of AI in Software Development',
  'future-of-ai-software-development',
  'Exploring how artificial intelligence is transforming the way we build software, from code generation to automated testing and deployment.',
  E'# The Future of AI in Software Development\n\nArtificial intelligence is revolutionizing software development in ways we couldn''t have imagined just a few years ago. From intelligent code completion to automated bug detection, AI tools are becoming indispensable.\n\n## Code Generation Revolution\n\nModern AI models can now generate entire functions, classes, and even full applications based on natural language descriptions. This doesn''t replace developers—it amplifies their capabilities.\n\n## The Human Element\n\nWhile AI handles repetitive tasks, developers can focus on creative problem-solving, architecture decisions, and building meaningful user experiences.',
  'https://images.pexels.com/photos/8386440/pexels-photo-8386440.jpeg?auto=compress&cs=tinysrgb&w=1200',
  id,
  'Artificial Intelligence',
  ARRAY['AI', 'Machine Learning', 'Development'],
  8,
  true,
  now() - interval '2 days'
FROM authors WHERE name = 'Sarah Chen'
ON CONFLICT DO NOTHING;

INSERT INTO blog_posts (title, slug, excerpt, content, cover_image_url, author_id, category, tags, read_time_minutes, published, published_at)
SELECT 
  'Building Scalable Microservices Architecture',
  'building-scalable-microservices',
  'A comprehensive guide to designing and implementing microservices that can handle millions of requests while maintaining reliability and performance.',
  E'# Building Scalable Microservices Architecture\n\nMicroservices have become the de facto standard for building large-scale applications. But scaling them properly requires careful planning and the right tools.\n\n## Key Principles\n\n1. **Service Independence**: Each service should be deployable independently\n2. **Data Ownership**: Services own their data stores\n3. **Communication Patterns**: Choose between synchronous and asynchronous wisely\n\n## Technologies That Matter\n\nKubernetes, service meshes, and event-driven architectures form the backbone of modern microservices.',
  'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=1200',
  id,
  'Cloud Computing',
  ARRAY['Microservices', 'DevOps', 'Architecture'],
  12,
  true,
  now() - interval '5 days'
FROM authors WHERE name = 'Marcus Rodriguez'
ON CONFLICT DO NOTHING;

INSERT INTO blog_posts (title, slug, excerpt, content, cover_image_url, author_id, category, tags, read_time_minutes, published, published_at)
SELECT 
  'Zero Trust Security: A Modern Approach',
  'zero-trust-security-modern-approach',
  'Understanding the principles of zero trust security and why traditional perimeter-based security is no longer sufficient in today''s cloud-native world.',
  E'# Zero Trust Security: A Modern Approach\n\nThe traditional "castle and moat" security model is dead. In a world of cloud services, remote work, and distributed systems, we need a new approach.\n\n## Never Trust, Always Verify\n\nZero trust assumes breach and verifies each request as if it originated from an open network. No implicit trust based on network location.\n\n## Implementation Strategy\n\n- Strong identity verification\n- Least privilege access\n- Microsegmentation\n- Continuous monitoring',
  'https://images.pexels.com/photos/60504/security-protection-anti-virus-software-60504.jpeg?auto=compress&cs=tinysrgb&w=1200',
  id,
  'Cybersecurity',
  ARRAY['Security', 'Zero Trust', 'Cloud'],
  10,
  true,
  now() - interval '1 day'
FROM authors WHERE name = 'Emily Watson'
ON CONFLICT DO NOTHING;

INSERT INTO blog_posts (title, slug, excerpt, content, cover_image_url, author_id, category, tags, read_time_minutes, published, published_at)
SELECT 
  'WebAssembly: The Future of Web Performance',
  'webassembly-future-web-performance',
  'Discover how WebAssembly is enabling near-native performance in web applications and opening new possibilities for web development.',
  E'# WebAssembly: The Future of Web Performance\n\nWebAssembly (Wasm) is changing the game for web performance. It allows developers to run code written in languages like C++, Rust, and Go directly in the browser at near-native speeds.\n\n## Why It Matters\n\nComplex applications that were previously impossible in the browser—like video editing, 3D modeling, and scientific simulations—are now feasible.\n\n## Real-World Applications\n\nCompanies like Figma, Google Earth, and AutoCAD are already using WebAssembly to deliver desktop-class experiences in the browser.',
  'https://images.pexels.com/photos/11035471/pexels-photo-11035471.jpeg?auto=compress&cs=tinysrgb&w=1200',
  id,
  'Web Development',
  ARRAY['WebAssembly', 'Performance', 'JavaScript'],
  7,
  true,
  now() - interval '3 days'
FROM authors WHERE name = 'Marcus Rodriguez'
ON CONFLICT DO NOTHING;

INSERT INTO blog_posts (title, slug, excerpt, content, cover_image_url, author_id, category, tags, read_time_minutes, published, published_at)
SELECT 
  'Machine Learning Model Optimization Techniques',
  'ml-model-optimization-techniques',
  'Learn practical techniques for optimizing machine learning models to reduce inference time and computational costs without sacrificing accuracy.',
  E'# Machine Learning Model Optimization Techniques\n\nDeploying machine learning models in production requires more than just good accuracy. You need models that are fast, efficient, and cost-effective.\n\n## Quantization\n\nReducing model precision from 32-bit to 8-bit can dramatically reduce model size and increase inference speed with minimal accuracy loss.\n\n## Pruning and Distillation\n\nRemoving unnecessary weights and training smaller models to mimic larger ones are powerful techniques for model compression.',
  'https://images.pexels.com/photos/8386434/pexels-photo-8386434.jpeg?auto=compress&cs=tinysrgb&w=1200',
  id,
  'Artificial Intelligence',
  ARRAY['Machine Learning', 'Optimization', 'Performance'],
  15,
  true,
  now() - interval '7 days'
FROM authors WHERE name = 'Sarah Chen'
ON CONFLICT DO NOTHING;

INSERT INTO blog_posts (title, slug, excerpt, content, cover_image_url, author_id, category, tags, read_time_minutes, published, published_at)
SELECT 
  'API Security Best Practices for 2025',
  'api-security-best-practices-2025',
  'Essential security practices every developer should implement to protect their APIs from modern threats and vulnerabilities.',
  E'# API Security Best Practices for 2025\n\nAPIs are the backbone of modern applications, making them prime targets for attacks. Here''s how to keep them secure.\n\n## Authentication and Authorization\n\nImplement OAuth 2.0 and JWT tokens properly. Use refresh tokens and keep access tokens short-lived.\n\n## Rate Limiting and Throttling\n\nProtect your API from abuse and DDoS attacks with intelligent rate limiting.\n\n## Input Validation\n\nNever trust client input. Validate everything server-side.',
  'https://images.pexels.com/photos/5380664/pexels-photo-5380664.jpeg?auto=compress&cs=tinysrgb&w=1200',
  id,
  'Cybersecurity',
  ARRAY['API', 'Security', 'Best Practices'],
  9,
  true,
  now() - interval '4 days'
FROM authors WHERE name = 'Emily Watson'
ON CONFLICT DO NOTHING;