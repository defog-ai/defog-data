
CREATE TABLE public.border_info (
    state_name text,
    border text
);


CREATE TABLE public.city (
    city_name text,
    population bigint,
    country_name text DEFAULT ''::text NOT NULL,
    state_name text
);


CREATE TABLE public.highlow (
    state_name text,
    highest_elevation text,
    lowest_point text,
    highest_point text,
    lowest_elevation text
);


CREATE TABLE public.lake (
    lake_name text,
    area double precision,
    country_name text DEFAULT ''::text NOT NULL,
    state_name text
);


CREATE TABLE public.mountain (
    mountain_name text,
    mountain_altitude bigint,
    country_name text DEFAULT ''::text NOT NULL,
    state_name text
);


CREATE TABLE public.river (
    river_name text,
    length bigint,
    country_name text DEFAULT ''::text NOT NULL,
    traverse text
);


CREATE TABLE public.state (
    state_name text,
    population bigint,
    area double precision,
    country_name text DEFAULT ''::text NOT NULL,
    capital text,
    density double precision
);


INSERT INTO public.border_info (state_name, border) VALUES
('California', 'Nevada'),
('California', 'Arizona'),
('California', 'Oregon'),
('Texas', 'Louisiana'),
('Texas', 'Oklahoma'),
('Texas', 'New Mexico'),
('Florida', 'Alabama'),
('Florida', 'Georgia'),
('Florida', 'Atlantic Ocean'),
('New York', 'Pennsylvania'),
('New York', 'Connecticut'),
('New York', 'Massachusetts')
;

INSERT INTO public.city (city_name, population, country_name, state_name) VALUES
('New York', 1000000, 'United States', 'New York'),
('Los Angeles', 5000000, 'United States', 'California'),
('Chicago', 1500000, 'United States', 'Illinois'),
('Houston', 2000000, 'United States', 'Texas'),
('Toronto', 800000, 'Canada', 'Ontario'),
('Mexico City', 600000, 'Mexico', 'Distrito Federal'),
('Sao Paulo', 3000000, 'Brazil', 'Sao Paulo'),
('Mumbai', 1200000, 'India', 'Maharashtra'),
('London', 900000, 'United Kingdom', 'England'),
('Tokyo', 700000, 'Japan', 'Tokyo')
;

INSERT INTO public.highlow (state_name, highest_elevation, lowest_point, highest_point, lowest_elevation) VALUES
('California', '4421', 'Death Valley', 'Mount Whitney', '-86'),
('Texas', '2667', 'Gulf of Mexico', 'Guadalupe Peak', '0'),
('Florida', NULL, 'Atlantic Ocean', 'Unnamed location', '0'),
('New York', '1629', 'Atlantic Ocean', 'Mount Marcy', '0'),
('Ontario', NULL, 'Atlantic Ocean', 'Unnamed location', '0'),
('Sao Paulo', NULL, 'Atlantic Ocean', 'Unnamed location', '0'),
('Guangdong', NULL, 'South China Sea', 'Unnamed location', '0'),
('Maharashtra', NULL, 'Arabian Sea', 'Unnamed location', '0'),
('England', '978', 'North Sea', 'Scafell Pike', '0'),
('Tokyo', '3776', 'Pacific Ocean', 'Mount Fuji', '0')
;

INSERT INTO public.lake (lake_name, area, country_name, state_name) VALUES
('Lake Superior', 1000, 'United States', 'Michigan'),
('Lake Michigan', 500, 'United States', 'Michigan'),
('Lake Huron', 300, 'United States', 'Michigan'),
('Lake Erie', 200, 'United States', 'Ohio'),
('Lake Ontario', 400, 'United States', 'New York'),
('Lake Victoria', 800, 'Tanzania', NULL),
('Lake Tanganyika', 600, 'Tanzania', NULL),
('Lake Malawi', 700, 'Tanzania', NULL),
('Lake Baikal', 900, 'Russia', NULL),
('Lake Qinghai', 1200, 'China', NULL)
;

INSERT INTO public.mountain (mountain_name, mountain_altitude, country_name, state_name) VALUES
('Mount Everest', 10000, 'Nepal', NULL),
('K2', 5000, 'Pakistan', NULL),
('Kangchenjunga', 3000, 'Nepal', NULL),
('Lhotse', 2000, 'Nepal', NULL),
('Makalu', 4000, 'Nepal', NULL),
('Cho Oyu', 8000, 'Nepal', NULL),
('Dhaulagiri', 6000, 'Nepal', NULL),
('Manaslu', 7000, 'Nepal', NULL),
('Nanga Parbat', 9000, 'Pakistan', NULL),
('Annapurna', 1000, 'Nepal', NULL)
;

INSERT INTO public.river (river_name, length, country_name, traverse) VALUES
('Nile', 1000, 'Egypt', 'Cairo,Luxor,Aswan'),
('Amazon', 500, 'Brazil', 'Manaus,Belem'),
('Yangtze', 300, 'China', 'Shanghai,Wuhan,Chongqing'),
('Mississippi', 200, 'United States', 'New Orleans,Memphis,St. Louis'),
('Yukon', 400, 'Canada', 'Whitehorse,Dawson City'),
('Volga', 800, 'Russia', 'Moscow,Samara,Kazan'),
('Mekong', 600, 'Vietnam', 'Ho Chi Minh City,Phnom Penh'),
('Danube', 700, 'Germany', 'Passau,Vienna,Budapest'),
('Rhine', 900, 'Germany', 'Strasbourg,Frankfurt,Cologne'),
('Po', 100, 'Italy', 'Turin,Milan,Venice')
;

INSERT INTO public.state (state_name, population, area, country_name, capital, density) VALUES
('California', 100000, 10000, 'United States', 'Sacramento', 1000),
('Texas', 50000, 5000, 'United States', 'Austin', 1000),
('Florida', 150000, 15000, 'United States', 'Tallahassee', 1000),
('New York', 200000, 20000, 'United States', 'Albany', 1000),
('Ontario', 80000, 8000, 'Canada', 'Toronto', 1000),
('Sao Paulo', 50000, 6000, 'Brazil', 'Sao Paulo', 1000),
('Guangdong', 200000, 30000, 'China', 'Guangzhou', 1000),
('Maharashtra', 200000, 12000, 'India', 'Mumbai', 1000),
('England', 9000, 10000, 'United Kingdom', 'London', 1000),
('Tokyo', 70000, 50000, 'Japan', 'Tokyo', 1000),
('Ohio', 90000, 11000, 'United States', 'Columbus', 1000),
('Michigan', 120000, 9000, 'United States', 'Lansing', 1000)
;



