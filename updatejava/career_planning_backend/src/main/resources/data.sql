-- 初始化测试数据

-- 用户数据
INSERT INTO users (username, password, email, major, enrollment_date) 
VALUES ('admin', '$2a$10$XFE7nxHkCGGy5pMz8wXG8.6oWWJYhzBPVKbWbO6r5xqwTwBFbQHJu', 'admin@example.com', '计算机科学', '2023-09-01');

-- 职业数据
INSERT INTO careers (title, description, average_salary)
VALUES ('前端开发工程师', '负责网站和web应用程序的用户界面开发', '15-30K');

INSERT INTO careers (title, description, average_salary)
VALUES ('后端开发工程师', '负责服务器端应用程序和系统架构开发', '20-40K');

INSERT INTO careers (title, description, average_salary)
VALUES ('全栈开发工程师', '同时掌握前端和后端技术的全面开发者', '25-45K');

-- 职业所需技能
INSERT INTO career_required_skills (career_id, skill) VALUES (1, 'JavaScript');
INSERT INTO career_required_skills (career_id, skill) VALUES (1, 'React');
INSERT INTO career_required_skills (career_id, skill) VALUES (1, 'Vue');
INSERT INTO career_required_skills (career_id, skill) VALUES (1, 'HTML/CSS');

INSERT INTO career_required_skills (career_id, skill) VALUES (2, 'Java');
INSERT INTO career_required_skills (career_id, skill) VALUES (2, 'Spring Boot');
INSERT INTO career_required_skills (career_id, skill) VALUES (2, 'MySQL');
INSERT INTO career_required_skills (career_id, skill) VALUES (2, 'Redis');

INSERT INTO career_required_skills (career_id, skill) VALUES (3, 'JavaScript');
INSERT INTO career_required_skills (career_id, skill) VALUES (3, 'Node.js');
INSERT INTO career_required_skills (career_id, skill) VALUES (3, 'React');
INSERT INTO career_required_skills (career_id, skill) VALUES (3, 'MongoDB');

