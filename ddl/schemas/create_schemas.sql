/*-----------------------------------------------------
-- Schema Setup
-----------------------------------------------------*/

-- Create schemas
CREATE OR REPLACE SCHEMA raw;
CREATE OR REPLACE SCHEMA harmonized;
CREATE OR REPLACE SCHEMA analytics;
CREATE OR REPLACE SCHEMA public;  -- for shared utilities like file formats and stages
CREATE OR REPLACE SCHEMA automation;
