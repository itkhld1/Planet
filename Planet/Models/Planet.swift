//
//  Planet.swift
//  Planet
//
//  Created by itkhld on 2024-10-03.
//

import Foundation

struct Planet: Identifiable {
    let id = UUID()
    let name: String
    /// Radius on the Solar System map at 1×, in points. Roughly the cube root
    /// of the real diameter: compressed enough to fit, but still in order.
    let size: CGFloat
    let imageName: String
    let orbiteRadius: CGFloat
    let initialAngle: Double
    let description: String
    let diameter: String
    let distanceFromSun: String
    let dayLength: String
    let rotationDuration: Double
    let planet3DModel: String

    /// `description` is always English; this is what the UI should show.
    var localizedDescription: String {
        PlanetDetailsFa.shortDescription(for: name) ?? description
    }

    init(name: String, size: CGFloat, imageName: String, orbiteRadius: CGFloat, initialAngle: Double, description: String, diameter: String, distanceFromSun: String, dayLength: String, rotationDuration: Double, planet3DModel: String) {
        self.name = name
        self.size = size
        self.imageName = imageName
        self.orbiteRadius = orbiteRadius
        self.initialAngle = initialAngle
        self.description = description
        self.diameter = diameter
        self.distanceFromSun = distanceFromSun
        self.dayLength = dayLength
        self.rotationDuration = rotationDuration
        self.planet3DModel = planet3DModel
    }
}

struct Star: Identifiable {
    let id = UUID()
    let name: String
    let size: CGFloat
    let imageName: String
    let description: String
    let diameter: String
    let distanceFromCenter: String
    let surfaceTemperature: String
    let sun3DModel: String

    /// `description` is always English; this is what the UI should show.
    var localizedDescription: String {
        PlanetDetailsFa.shortDescription(for: name) ?? description
    }

    init(name: String, size: CGFloat, imageName: String, description: String, diameter: String, distanceFromCenter: String, surfaceTemperature: String, sun3DModel: String) {
        self.name = name
        self.size = size
        self.imageName = imageName
        self.description = description
        self.diameter = diameter
        self.distanceFromCenter = distanceFromCenter
        self.surfaceTemperature = surfaceTemperature
        self.sun3DModel = sun3DModel
    }
}

let sun = Star(
    name: "Sun",
    size: 80,
    imageName: "Sun",
    description: "The Sun is the star at the center of our solar system. It is a nearly perfect sphere of hot plasma. FUN FACT: The Sun accounts for about 99.86% of the mass of the solar system!",
    diameter: "1.39 million km",
    distanceFromCenter: "0 km (It is the center!)",
    surfaceTemperature: "5,500 °C",
    sun3DModel: "Sun"
)

let planets = [
    Planet(name: "Mercury", size: 6, imageName: "Mercury", orbiteRadius: 45, initialAngle: 0, description: "Mercury is the closest planet to the Sun. FUN FACT: Mercury has the most extreme temperature variations in the solar system, ranging from -173°C at night to 427°C during the day!", diameter: "4,880 km", distanceFromSun: "57.9 million km", dayLength: "58.6 Earth days", rotationDuration: 20, planet3DModel: "Mercury"),
    
    Planet(name: "Venus", size: 9, imageName: "Venus", orbiteRadius: 65, initialAngle: 45, description: "Venus is the second planet from the Sun. FUN FACT: A day on Venus (243 Earth days) is longer than a year on Venus (225 Earth days)!", diameter: "12,104 km", distanceFromSun: "108.2 million km", dayLength: "243 Earth days", rotationDuration: 100, planet3DModel: "Venus"),
    
    Planet(name: "Earth", size: 9.5, imageName: "Earth", orbiteRadius: 90, initialAngle: 90, description: "Earth is the third planet from the Sun and the only known planet to support life. FUN FACT: Earth is the only planet in the solar system not named after a god.", diameter: "12,742 km", distanceFromSun: "149.6 million km", dayLength: "24 hours", rotationDuration: 150, planet3DModel: "Earth"),
    
    Planet(name: "Mars", size: 7, imageName: "Mars", orbiteRadius: 110, initialAngle: 135, description: "Mars is the fourth planet from the Sun. FUN FACT: Mars has the largest volcano in the solar system, Olympus Mons, which is about three times the height of Mount Everest!", diameter: "6,779 km", distanceFromSun: "227.9 million km", dayLength: "24.6 hours", rotationDuration: 250, planet3DModel: "Mars"),
    
    Planet(name: "Jupiter", size: 17, imageName: "Jupiter", orbiteRadius: 135, initialAngle: 180, description: "Jupiter is the largest planet in the solar system. FUN FACT: Jupiter has a storm called the Great Red Spot.", diameter: "139,820 km", distanceFromSun: "778.5 million km", dayLength: "9.9 hours", rotationDuration: 300, planet3DModel: "Jupiter"),
    
    Planet(name: "Saturn", size: 20, imageName: "Saturn", orbiteRadius: 155, initialAngle: 225, description: "Saturn is famous for its rings. FUN FACT: Saturn’s rings are made of billions of pieces of ice and rock!", diameter: "116,460 km", distanceFromSun: "1.4 billion km", dayLength: "10.7 hours", rotationDuration: 500, planet3DModel: "Saturn"),
    
    Planet(name: "Uranus", size: 12, imageName: "Uranus", orbiteRadius: 175, initialAngle: 270, description: "Uranus is tilted on its side. FUN FACT: Uranus rotates on its side, possibly due to a massive collision in its past!", diameter: "50,724 km", distanceFromSun: "2.9 billion km", dayLength: "17.2 hours", rotationDuration: 700, planet3DModel: "Uranus"),
    
    Planet(name: "Neptune", size: 12, imageName: "Neptune", orbiteRadius: 195, initialAngle: 300, description: "Neptune is known for its strong winds. FUN FACT: Neptune has the fastest winds in the solar system, reaching speeds of 2,100 km/h!", diameter: "49,244 km", distanceFromSun: "4.5 billion km", dayLength: "16.1 hours", rotationDuration: 800, planet3DModel: "Neptune"),

    Planet(name: "Solar System", size: 0, imageName: "solar system", orbiteRadius: 0, initialAngle: 0, description: "", diameter: "", distanceFromSun: "", dayLength: "", rotationDuration: 0, planet3DModel: "Solar_System_Custom")
]

struct PlanetDetails {
    static let planetInfo: [String: String] = [
        "Solar System": """
            The Solar System is the Sun and everything bound to it by gravity: eight planets, their moons, five recognised dwarf planets, and countless asteroids, comets and lumps of ice and dust. It formed about 4.6 billion years ago and is our small corner of the Milky Way galaxy.

            At a Glance:
            - Age: About 4.6 billion years
            - Star: One — the Sun, a G-type main-sequence star
            - Planets: 8
            - Dwarf planets: 5 recognised — Ceres, Pluto, Haumea, Makemake and Eris
            - Known moons of the planets: 285 as of 2024
            - Width: About 9 billion km across the planets' orbits
            - Oldest thing in it: The Sun, which formed first

            How It Formed:
            - The Solar System began as a vast, slowly spinning cloud of gas and dust called the solar nebula. Gravity pulled the cloud inward until the centre grew hot and dense enough to ignite nuclear fusion, and the Sun was born.
            - The leftover material flattened into a spinning disc around the young Sun. Within that disc, dust grains stuck together into pebbles, pebbles into boulders, and boulders into planets — a process called accretion.
            - Close to the Sun it was too hot for ice to survive, so only rock and metal could clump together. That is why the inner planets are small and rocky while the outer ones, formed where ice was plentiful, grew huge.

            The Sun:
            - The Sun accounts for about 99.86% of all the mass in the Solar System. Everything else — every planet, moon and asteroid combined — makes up the remaining 0.14%.
            - Its gravity is what holds the whole system together and sets every orbit.
            - It is about 1.4 million km across, roughly 109 times wider than Earth.

            The Inner Planets:
            - Mercury, Venus, Earth and Mars are the terrestrial planets: small, dense worlds with solid rocky surfaces.
            - They have few moons between them — Mercury and Venus have none, Earth has one, and Mars has two small captured asteroids.
            - None of them have rings.

            The Asteroid Belt:
            - Between Mars and Jupiter lies a wide belt of rocky, metallic debris left over from the Solar System's formation.
            - Jupiter's gravity stirred this region so much that the material never managed to form a planet.
            - Ceres, the largest object in the belt, is big enough to be a dwarf planet.

            The Outer Planets:
            - Jupiter and Saturn are gas giants, made mostly of hydrogen and helium with no solid surface to stand on.
            - Uranus and Neptune are ice giants: much of their mass is water, ammonia and methane ices.
            - All four have ring systems, though only Saturn's are bright enough to be famous.
            - Between them they hold the great majority of the Solar System's moons.

            Beyond Neptune:
            - Kuiper Belt: A wide ring of icy bodies past Neptune's orbit, home to Pluto and the source of many short-period comets.
            - Oort Cloud: A vast, spherical shell of icy objects thought to surround the Solar System far beyond the Kuiper Belt. It is where long-period comets come from.
            - Heliosphere: The enormous bubble carved out by the solar wind. Its outer boundary, the heliopause, is where the Sun's influence finally gives way to interstellar space.

            Measuring the Distances:
            - Distances here are so large that kilometres become unwieldy, so astronomers use the astronomical unit (AU) — the average distance from Earth to the Sun, about 150 million km.
            - Mercury orbits at 0.39 AU, Earth at 1 AU, Jupiter at 5.2 AU and Neptune at about 30 AU.
            - Sunlight takes roughly 8 minutes to reach Earth, but more than 4 hours to reach Neptune.

            Small Bodies:
            - Asteroids: Rocky, metallic leftovers from the Solar System's formation, mostly found between Mars and Jupiter.
            - Comets: Icy bodies that grow glowing tails of gas and dust when they pass close to the Sun.
            - Meteoroids: Small fragments of rock or metal drifting through space. One that burns up in Earth's atmosphere is a meteor, and any piece that survives to reach the ground is a meteorite.

            Our Place in the Galaxy:
            - The Solar System sits in the Orion Arm, one of the Milky Way's spiral arms, about 26,000 light years from the galactic centre.
            - It orbits the centre of the galaxy at roughly 230 km/s, taking about 230 million years to complete one lap — a single galactic year.
            - The last time the Solar System was in this part of the galaxy, dinosaurs had not yet appeared on Earth.

            Exploration:
            - Voyager 1 and Voyager 2 (Launched 1977): Toured the outer planets and are now the most distant human-made objects. Voyager 1 crossed into interstellar space in 2012.
            - Cassini-Huygens (1997-2017): Orbited Saturn for 13 years and landed a probe on Titan.
            - New Horizons (Launched 2006): Gave us our first close-up look at Pluto in 2015 before heading deeper into the Kuiper Belt.
            - Juno (Launched 2011): Still orbiting Jupiter, studying its atmosphere and interior.

            Interesting Facts:
            - Everything Orbits: Every planet orbits the Sun in the same direction, and nearly all of them in almost the same flat plane — a leftover signature of the disc they formed from.
            - Mostly Empty: Despite holding eight planets and hundreds of moons, the Solar System is overwhelmingly empty space.
            - Jupiter the Shield: Jupiter's huge gravity captures or deflects many comets and asteroids, helping to protect the inner planets.
            - Still Being Explored: Uranus and Neptune have each been visited only once, by Voyager 2, so much about them remains unknown.
            """,

        "Mercury": """
            Mercury is the smallest and innermost planet in the Solar System. It’s known for its extreme temperatures and fast orbit around the Sun. Here’s a breakdown of its key characteristics:

            General Characteristics:
            - Type: Terrestrial planet
            - Radius: 2,440 km (1,516 miles)
            - Diameter: 4,880 km (3,032 miles)
            - Mass: 3.30 × 10^23 kg (about 5.5% of Earth's mass)
            - Surface Area: 74.8 million km²
            - Orbital Distance from the Sun: 57.9 million kilometers (0.39 Astronomical Units or AU)
            - Rotation Period (Day): 59 Earth days
            - Revolution Period (Year): 88 Earth days (Mercury has the shortest year in the Solar System)
            
            Structure:
            - Core: Mercury has a large iron core, which is about 85% of the planet's radius, making it proportionally larger than any other planet’s core in the Solar System.
            - Mantle & Crust: It has a relatively thin silicate mantle and crust, only about 400 km thick.
            
            Surface:
            - Mercury's surface is covered with craters, similar to the Moon, due to its lack of a substantial atmosphere to protect it from impacts. Some of the notable features include:

            Caloris Basin:
            - One of the largest impact basins in the Solar System.
            - Scarps (cliffs): These are formed by the planet’s contraction as it cooled.
            
            Atmosphere:
            - Mercury has a very thin atmosphere, known as an exosphere, which is composed of atoms blasted off its surface by the solar wind. This atmosphere contains oxygen, sodium, hydrogen, helium, and potassium. It’s so thin that it can’t trap heat, leading to extreme temperature variations.

            Temperature:
            - Daytime Temperatures: Can reach up to 430°C (800°F).
            - Nighttime Temperatures: Can drop as low as -180°C (-290°F). This drastic difference is due to Mercury's lack of atmosphere to retain heat.
            
            Orbit and Rotation:
            - Mercury has a unique 3:2 spin-orbit resonance, meaning it rotates three times on its axis for every two orbits it makes around the Sun. This causes long days and nights on Mercury (about 176 Earth days between sunrises).

            Magnetic Field:
            - Despite its small size, Mercury has a magnetic field, though it is much weaker than Earth’s. The magnetic field is generated by its partially molten iron core.

            Moons:
            - Mercury has no moons or rings.
            
            Exploration:
            - Mariner 10 (1974-1975): The first spacecraft to visit Mercury, providing the first close-up images.
            - MESSENGER (2011-2015): The first mission to orbit Mercury, offering detailed information about its geology, magnetic field, and thin atmosphere.
            - BepiColombo (Launched in 2018): A joint mission by the European Space Agency (ESA) and the Japan Aerospace Exploration Agency (JAXA), currently en route to study Mercury more closely.
            
            Interesting Facts:
            - Fastest Planet: Mercury is the fastest planet in the Solar System, traveling at an average speed of about 47 km/s (105,000 mph) around the Sun.
            - Daytime and Year Length: One day on Mercury (sunrise to sunrise) is longer than its year because of its slow rotation relative to its orbit.
            Closest to the Sun:
            - Mercury is the closest planet to the Sun, making its proximity a key factor in its extreme temperatures.
            """,
        
        "Venus": """
            Venus is the second planet from the Sun and is often referred to as Earth’s "sister planet" due to their similar size and composition. However, Venus has a dramatically different environment. Here are key facts:

            General Characteristics:
            - Type: Terrestrial planet
            - Radius: Approximately 6,051.8 km (3,760 miles)
            - Diameter: 12,104 km (7,521 miles) — about 95% of Earth's diameter
            - Mass: 4.87 × 10^24 kg (about 81.5% of Earth's mass)
            - Surface Area: 460.2 million km²
            - Orbital Distance from the Sun: Around 108.2 million kilometers (0.72 Astronomical Units)
            - Rotation Period (Day): 243 Earth days (Venus has a very slow, retrograde rotation, meaning it spins in the opposite direction of most planets, including Earth)
            - Revolution Period (Year): 225 Earth days
            
            Surface and Structure:
            - Surface: Venus has a rocky surface with mountains, plains, and numerous volcanoes. It’s covered by smooth volcanic plains with very few impact craters, suggesting that volcanic resurfacing has occurred over time.
            - Mountains and Volcanism: Venus features large volcanic structures such as Maxwell Montes, the highest mountain on Venus. Volcanic activity is believed to be ongoing, though there is no direct evidence of eruptions.
            - Surface Temperature: Venus is the hottest planet in the Solar System, with an average surface temperature of about 465°C (867°F). This intense heat is due to a runaway greenhouse effect, where thick clouds trap heat in the atmosphere.
            
            Atmosphere:
            - Composition: Venus’s atmosphere is mostly carbon dioxide (about 96.5%) with clouds of sulfuric acid, making it highly toxic. There is also a small amount of nitrogen (3.5%) and trace gases.
            - Pressure: The atmospheric pressure on Venus is about 92 times that of Earth, equivalent to being about 900 meters (3,000 feet) underwater.
            - Weather: Venus experiences constant lightning and thick clouds that completely block the planet's surface from view. Winds in the upper atmosphere can reach speeds of 360 km/h (224 mph).
            
            Orbit and Rotation:
            - Retrograde Rotation: Venus rotates on its axis in the opposite direction to most planets, meaning the Sun rises in the west and sets in the east. One day on Venus is longer than its year.
            - No Seasons: Because of its nearly vertical axis (tilt of only about 3 degrees), Venus doesn’t have significant seasons.
            
            Moons:
            - Venus has no natural satellites (moons), similar to Mercury.
            
            Exploration:
            - Venus has been studied by many missions due to its proximity to Earth and its intriguing conditions:
            - Venera Program (USSR, 1960s-1980s): The first spacecraft to land on Venus and send back data was Venera 7, followed by several others that transmitted data and images before being destroyed by the harsh conditions.
            - Magellan Mission (NASA, 1990-1994): Mapped Venus’s surface using radar, as the planet's thick clouds prevent direct visual observation.
            - Akatsuki (Japan, 2015-present): Still orbiting Venus, studying its atmosphere and weather patterns.
            
            Interesting Facts:
            - Earth’s "Evil Twin": Venus is often called Earth’s twin because of its similar size and composition, but its climate and environment are drastically different.
            - Sulfuric Acid Clouds: The thick clouds that cover Venus are made up of sulfuric acid droplets, contributing to its harsh environment.
            - Greenhouse Effect: Venus provides an extreme example of the greenhouse effect, where gases in the atmosphere trap heat, making it much hotter than Mercury, despite being farther from the Sun.
            - Slow Spin: A day on Venus (243 Earth days) is longer than its year (225 Earth days), making it one of the slowest-spinning planets.
            """,
        
        
        "Earth": """
            Earth is the third planet from the Sun and the only known planet to support life. Here are some key details:

            General Characteristics:
            - Type: Terrestrial planet
            - Radius: Approximately 6,371 km (3,959 miles)
            - Diameter: About 12,742 km (7,918 miles)
            - Mass: 5.97 × 10^24 kg
            - Surface Area: 510.1 million km², with about 71% covered by water.
            - Orbital Distance from the Sun: Around 149.6 million kilometers (1 Astronomical Unit or AU)
            - Rotation Period (Day): 24 hours
            - Revolution Period (Year): 365.25 days

            Structure:
            - Core: A solid inner core composed mainly of iron and nickel, surrounded by a molten outer core.
            - Mantle: Made of silicate materials, responsible for tectonic activity.
            - Crust: The solid outer layer on which life exists, divided into tectonic plates.

            Atmosphere:
            - Earth's atmosphere is made up of 78% nitrogen, 21% oxygen, and 1% other gases, including argon, carbon dioxide, and trace amounts of water vapor. It protects life by absorbing ultraviolet radiation from the Sun and reducing temperature extremes between day and night.

            Unique Features:
            - Life: Earth is the only planet known to have liquid water on its surface and conditions suitable for life as we know it.
            - Tectonic Plates: The surface of Earth is dynamic, consisting of several tectonic plates that move, causing earthquakes, volcanic activity, and the formation of mountains.
            - Magnetic Field: Earth's magnetic field, generated by its molten iron outer core, shields the planet from harmful solar radiation.

            Orbit and Seasons:
            - Earth’s orbit around the Sun is slightly elliptical, and the planet is tilted at about 23.5 degrees. This tilt, combined with its orbit, causes the changing seasons.

            Moons:
            - Earth has one natural satellite, the Moon, which stabilizes its axial tilt and affects tides. The Moon is the fifth-largest moon in the Solar System.
            """,
        
        
        "Mars": """
            Mars, often called the "Red Planet," is the fourth planet from the Sun and has fascinated scientists and the public alike for decades. Its surface features and potential for past or present life make it one of the most studied planets in the Solar System.

            General Characteristics:
            - Type: Terrestrial planet
            - Radius: About 3,390 km (2,106 miles)
            - Diameter: 6,779 km (4,212 miles) — about half the size of Earth
            - Mass: 6.42 × 10^23 kg (about 11% of Earth's mass)
            - Surface Area: 144.8 million km² (roughly the same surface area as all of Earth's continents combined)
            - Orbital Distance from the Sun: Around 227.9 million kilometers (1.52 Astronomical Units)
            - Rotation Period (Day): 24.6 Earth hours (a "day" on Mars, also called a sol, is just slightly longer than an Earth day)
            - Revolution Period (Year): 687 Earth days (almost twice as long as an Earth year)
            
            Surface and Structure:
            - Surface: Mars has a barren, desert-like surface covered in dust and rocky landscapes. The red appearance comes from iron oxide (rust) in its soil.
            - Volcanoes and Mountains: Mars is home to Olympus Mons, the largest volcano and tallest planetary mountain in the Solar System, standing about 22 km (13.6 miles) high.
            - Valleys and Canyons: The planet features the Valles Marineris, a system of canyons that stretches over 4,000 km (2,500 miles), making it one of the largest canyons in the Solar System.
            - Polar Ice Caps: Mars has ice caps at its poles made of both water ice and carbon dioxide (dry ice). These caps grow and shrink with the changing seasons.
            
            Atmosphere:
            - Composition: Mars' atmosphere is thin, composed mostly of carbon dioxide (95.3%), with small amounts of nitrogen (2.7%), argon (1.6%), and traces of oxygen and water vapor.
            - Pressure: The atmospheric pressure on Mars is less than 1% of Earth’s, meaning the air is very thin, making it impossible for humans to breathe without assistance.
            - Weather: Mars experiences dust storms, some of which can engulf the entire planet. These storms are the largest in the Solar System, and they can last for months. The temperature can vary from 20°C (68°F) during the day to -100°C (-148°F) at night.
            
            Water on Mars:
            - Mars once had liquid water on its surface, as evidenced by ancient river valleys, lake beds, and minerals that only form in water. Today, most of the water is locked in ice at the poles or underground, though recent evidence suggests there may be briny water flowing seasonally on Mars' surface.

            Moons:
            - Phobos: The larger of Mars' two moons, Phobos is an irregularly shaped object that is slowly spiraling inward toward Mars. It is expected to crash into the planet or break up into a ring in about 50 million years.
            - Deimos: The smaller of the two moons, Deimos is also irregularly shaped and orbits Mars at a greater distance than Phobos. Both moons are thought to be captured asteroids from the asteroid belt.
            
            Exploration:
            - Mars has been the subject of numerous missions aimed at exploring its surface, atmosphere, and potential for life:

            Rovers:
            - Spirit and Opportunity (NASA, 2004-2018): These twin rovers found evidence that water once flowed on Mars.
            - Curiosity (NASA, 2012-present): Still operating, Curiosity is exploring Gale Crater and has found signs of ancient microbial life.
            - Perseverance (NASA, 2021-present): Currently exploring Mars, Perseverance is collecting samples for possible return to Earth and searching for signs of past life. It also brought the first helicopter, Ingenuity, to Mars.
            
            Orbiters:
            - Mars Odyssey (NASA, 2001-present): Mapping the planet’s surface and detecting hydrogen in the soil, indicating the presence of water ice.
            - Mars Reconnaissance Orbiter (NASA, 2006-present): Provides high-resolution images of Mars’ surface and has found significant evidence of liquid water.
            
            Potential for Life:
            - While no definitive evidence of life has been found on Mars, the discovery of methane in its atmosphere, seasonal changes in gas concentrations, and the past presence of water make Mars a candidate for the search for microbial life, past or present.

            Future Missions:
            - Mars is central to plans for future exploration, including human missions. NASA and other space agencies are preparing for human exploration of Mars in the 2030s. Elon Musk’s SpaceX also has ambitious plans to colonize Mars, with the goal of making humanity a multi-planetary species.

            Interesting Facts:
            - "Martian Day": A Martian day (called a "sol") is just slightly longer than an Earth day, at 24 hours and 39 minutes.
            - Dust Storms: Mars is famous for its planet-wide dust storms that can last for weeks or months.
            - Mars' Thin Atmosphere: Its thin atmosphere and lack of a global magnetic field allow for solar wind to strip away the atmosphere over time, contributing to its current state.
            - Colonization Candidate: Mars is considered a prime candidate for human colonization due to its relative proximity to Earth and the potential for resources like water ice.
            """,
        
        
        "Jupiter": """
            Jupiter is the largest planet in the Solar System and is known for its massive size, dynamic atmosphere, and many moons. It's a gas giant with no solid surface and plays a significant role in shaping the Solar System’s environment.

            General Characteristics:
            - Type: Gas giant
            - Radius: Approximately 69,911 km (43,441 miles)
            - Diameter: 142,984 km (88,846 miles) — about 11 times the diameter of Earth
            - Mass: 1.90 × 10^27 kg (about 318 times the mass of Earth)
            - Surface Area: 61.42 billion km²
            - Orbital Distance from the Sun: About 778.5 million kilometers (5.2 Astronomical Units)
            - Rotation Period (Day): 9.93 hours (Jupiter has the fastest rotation of any planet in the Solar System)
            - Revolution Period (Year): 11.86 Earth years
            
            Atmosphere:
            - Jupiter’s atmosphere is composed mostly of hydrogen (about 90%) and helium (about 10%), similar to the Sun. It also contains trace amounts of methane, ammonia, water vapor, and other gases.
            - Cloud Bands: Jupiter is famous for its distinct bands of clouds, made of ammonia and water, which rotate in opposite directions, causing intense storms and turbulent weather patterns.
            - Great Red Spot: The planet’s most famous feature, the Great Red Spot, is a massive storm larger than Earth that has been raging for at least 400 years. Its winds can reach speeds of over 400 km/h (250 mph).
            - Storms: Besides the Great Red Spot, Jupiter has many other cyclonic storms, some appearing and disappearing within days or months.
            
            Structure:
            - Core: Jupiter is believed to have a dense core made of heavier elements, but this core is surrounded by a vast layer of metallic hydrogen. The core's exact composition and size are still under investigation.
            - Mantle: The planet lacks a solid surface. Instead, its atmosphere transitions into a deep ocean of liquid hydrogen, which further compresses into metallic hydrogen due to the immense pressure inside the planet.
            - Magnetic Field: Jupiter has the strongest magnetic field in the Solar System, generated by the movement of metallic hydrogen in its interior. This magnetic field is 20,000 times stronger than Earth’s and creates a vast magnetosphere that extends millions of kilometers into space.
            
            Moons:
            - Jupiter has 95 confirmed moons as of 2024, making it the planet with the most moons in the Solar System. The four largest moons, known as the Galilean moons, were discovered by Galileo Galilei in 1610:

            - Io: The most volcanically active body in the Solar System, covered in lava flows and sulfur.
            Europa: A frozen moon with a subsurface ocean beneath its icy crust, making it a prime candidate in the search for extraterrestrial life.
            - Ganymede: The largest moon in the Solar System, even bigger than Mercury, and the only moon known to have its own magnetic field.
            - Callisto: Heavily cratered and considered one of the oldest surfaces in the Solar System.
            
            Rings:
            - Jupiter has a faint ring system, primarily composed of dust particles ejected by its moons. Unlike Saturn’s bright and large rings, Jupiter’s rings are thin and almost invisible, discovered only after spacecraft observations.

            Exploration:
            - Jupiter has been studied by numerous spacecraft, including:

            - Pioneer 10 and Pioneer 11 (1973-1974): The first spacecraft to fly by Jupiter, capturing data and images.
            Voyager 1 and Voyager 2 (1979): Provided detailed photographs and discovered Jupiter’s faint rings.
            Galileo Mission (1995-2003): The first spacecraft to orbit Jupiter, it studied the planet, its moons, and its magnetosphere extensively.
            - Juno (2016-present): Currently orbiting Jupiter, Juno is providing insights into Jupiter’s atmosphere, gravity field, magnetic field, and internal structure.
            
            Interesting Facts:
            - Fastest Rotation: Jupiter’s rapid rotation causes it to bulge at the equator, giving it an oblate shape.
            Gigantic Magnetosphere: Jupiter’s magnetic field is so vast that it creates intense radiation belts around the planet, which are hazardous to spacecraft and any potential life.
            - Auroras: Like Earth, Jupiter has auroras near its poles, but they are much more powerful and are driven by its immense magnetic field and interaction with its moons, especially Io.
            - Gravitational Influence: Jupiter’s massive gravity influences the orbits of many bodies in the Solar System, including comets and asteroids. It is thought to act as a "cosmic vacuum," protecting the inner planets by capturing or deflecting potentially harmful comets and asteroids.
            
            Potential for Life:
            - While Jupiter’s environment is too harsh for life as we know it, some of its moons, particularly Europa, hold the potential for harboring life due to the presence of liquid water beneath its icy surface.
            """,
        
        
        "Saturn": """
            Saturn is the sixth planet from the Sun and the second-largest planet in the Solar System, best known for its spectacular ring system. Like Jupiter, Saturn is a gas giant with a composition primarily of hydrogen and helium. Its unique features and stunning rings make it one of the most fascinating planets to observe and study.

            General Characteristics:
            - Type: Gas giant
            - Radius: Approximately 58,232 km (36,184 miles)
            - Diameter: 120,536 km (74,897 miles) — about 9.5 times Earth's diameter
            - Mass: 5.68 × 10^26 kg (about 95 times Earth's mass)
            - Surface Area: 42.7 billion km²
            - Orbital Distance from the Sun: About 1.43 billion kilometers (9.58 Astronomical Units)
            - Rotation Period (Day): 10.7 Earth hours (Saturn also rotates very quickly, similar to Jupiter)
            - Revolution Period (Year): 29.4 Earth years
            
            Rings:
            - Saturn’s rings are its most defining feature. They are made up of countless small particles, ranging in size from micrometers to meters, composed mostly of water ice with some dust and rocky debris.

            - Ring System: Saturn's rings are divided into several sections, labeled from A to G. The main rings (A, B, C) are the most prominent, with the Cassini Division, a large gap, separating rings A and B.
            - Thickness: Despite their vast size, the rings are extremely thin, typically only about 10 meters (33 feet) thick.
            - Origin: It’s still debated whether Saturn's rings are remnants of a destroyed moon, or material left over from the formation of the planet itself.
            
            Atmosphere:
            - Saturn’s atmosphere is composed primarily of hydrogen (96%) and helium (3%), with trace amounts of methane, ammonia, and other gases.
            - Cloud Bands: Like Jupiter, Saturn has a banded cloud structure, but the bands are fainter and less colorful. The upper atmosphere consists of ammonia ice clouds, with deeper layers of water clouds and ammonium hydrosulfide clouds.
            - Storms: Saturn has powerful storms, including massive, long-lasting cyclones at its poles. The planet's north pole features a strange, six-sided hexagonal storm, which is still not fully understood. These storms can have wind speeds of up to 1,800 km/h (1,100 mph).
            - Great White Spot: Saturn occasionally experiences enormous storm systems known as the "Great White Spot," which appear roughly every 30 Earth years.
            
            Structure:
            - Core: Saturn is believed to have a dense core made of heavy elements like iron, nickel, and rock, surrounded by a thick layer of metallic hydrogen.
            - Magnetic Field: Saturn’s magnetic field is not as strong as Jupiter’s but is still quite powerful. It generates auroras at the planet's poles, similar to Earth and Jupiter.
            
            Moons:
            - Saturn has 146 confirmed moons as of 2024, with 83 officially named. The most notable moons include:
            - Titan: The largest of Saturn’s moons and the second-largest moon in the Solar System (larger than Mercury), Titan has a thick atmosphere primarily composed of nitrogen, with clouds of methane and ethane. It has liquid methane and ethane lakes on its surface, making it the only other body in the Solar System known to have stable liquids on its surface.
            - Enceladus: A small, icy moon with a subsurface ocean beneath its ice shell. Enceladus has geysers that spew water vapor and organic molecules from its southern pole, making it a prime candidate in the search for extraterrestrial life.
            - Rhea: The second-largest moon of Saturn, covered with ice and heavily cratered.
            - Iapetus: Known for its striking two-tone coloration, with one side much darker than the other.
            - Mimas: Sometimes called the "Death Star moon" due to a large crater that gives it a similar appearance to the Death Star from Star Wars.
            
            Rings and Moons Interactions:
            - Many of Saturn’s moons interact with its rings, influencing their shape and structure. For example, some moons, called shepherd moons, help maintain the sharp edges of the rings. The gravitational influence of larger moons like Titan also causes gaps and waves in the ring system.

            Exploration:
            - Saturn has been studied by several space missions, but the most detailed and significant one was the Cassini-Huygens mission:
            - Cassini (1997-2017): Cassini orbited Saturn for 13 years, sending back thousands of images and invaluable data. It studied Saturn’s rings, moons, and atmosphere in detail, and even delivered the Huygens probe to land on Titan, the first landing ever on an outer Solar System body.
            - Huygens Probe (2005): Huygens provided the first direct data from Titan’s surface, revealing a landscape with liquid methane rivers and lakes.
            
            Interesting Facts:
            - Density: Saturn is the least dense of all the planets in the Solar System. Its overall density is so low that it would float in water if there were a body of water large enough to hold it.
            - Shape: Due to its rapid rotation, Saturn is oblate, meaning it is noticeably flattened at the poles and bulging at the equator.
            - Ring Age Debate: There is ongoing debate about whether Saturn's rings are relatively young (formed within the last 100 million years) or if they are ancient, possibly as old as the planet itself.
            
            Potential for Life:
            - While Saturn itself is not hospitable to life, some of its moons, particularly Titan and Enceladus, are considered potential candidates for supporting life. The discovery of a subsurface ocean on Enceladus and the complex organic chemistry on Titan has spurred interest in future missions to these moons.
            """,
        
        
        "Uranus": """
            Uranus is the seventh planet from the Sun and is unique in many ways compared to the other planets in the Solar System. It’s an ice giant, meaning that its composition includes more ices (water, ammonia, methane) along with hydrogen and helium, and it has an unusual axial tilt, causing it to rotate on its side.

            General Characteristics:
            - Type: Ice giant
            - Radius: Approximately 25,362 km (15,759 miles)
            - Diameter: 50,724 km (31,518 miles) — about 4 times the diameter of Earth
            - Mass: 8.68 × 10^25 kg (about 14.5 times Earth's mass)
            - Surface Area: 8.1 billion km²
            - Orbital Distance from the Sun: About 2.87 billion kilometers (19.2 Astronomical Units)
            - Rotation Period (Day): 17.24 Earth hours
            - Revolution Period (Year): 84 Earth years
            
            Axial Tilt:
            - One of Uranus's most distinctive features is its extreme axial tilt of about 98 degrees, which causes the planet to effectively rotate on its side. This unique orientation results in extreme seasonal variations, with each pole experiencing 42 years of continuous sunlight followed by 42 years of darkness as Uranus orbits the Sun.

            Atmosphere:
            - Uranus’s atmosphere is mostly made up of hydrogen (82.5%) and helium (15.2%), with methane (2.3%) giving the planet its blue-green color.
            - Methane Absorption: The methane in Uranus’s upper atmosphere absorbs red light, giving the planet its distinct cyan or pale blue color.
            - Temperature: Uranus is the coldest planet in the Solar System, with minimum atmospheric temperatures dropping to -224°C (-371°F). Despite being farther from the Sun, Neptune emits more heat than Uranus.
            - Cloud Layers: Beneath the upper methane haze, Uranus has cloud layers made of water, ammonia, and hydrogen sulfide, although they are difficult to observe directly due to the planet’s thick atmosphere.
            
            Structure:
            - Core: Uranus is believed to have a small rocky core, about the size of Earth, surrounded by an icy mantle composed of water, ammonia, and methane ices.
            - Icy Composition: It’s referred to as an ice giant because a significant portion of its mass consists of these icy materials.
            Outer Layers: Surrounding the icy mantle is a thick layer of hydrogen and helium, similar to gas giants like Jupiter and Saturn, though much smaller in quantity.
            
            Rings:
            - Uranus has a faint ring system made up of dark particles, which were first discovered in 1977. There are 13 known rings, and they are composed primarily of small, dark objects. The rings of Uranus are much less prominent than those of Saturn, and they are relatively young in astronomical terms.
            - Narrow and Dark: Unlike Saturn’s bright, broad rings, Uranus's rings are narrow and mostly made of dark material, likely carbon-rich particles.
            
            Moons:
            - Uranus has 27 known moons, most of which are named after characters from the works of William Shakespeare and Alexander Pope. The largest moons include:
            - Titania: The largest of Uranus's moons, it is heavily cratered and has evidence of geological activity, like faults and valleys.
            - Oberon: The second-largest moon, known for its heavily cratered surface.
            - Ariel: Has fewer craters than the others and shows signs of recent geological activity, such as valleys and smooth plains.
            - Umbriel: The darkest of Uranus's major moons, it has an old, heavily cratered surface.
            - Miranda: The smallest and most geologically active of Uranus’s major moons, Miranda has large canyons, cliffs, and unique surface features, making it one of the strangest moons in the Solar System.
            
            Magnetic Field:
            - Uranus’s magnetic field is also unusual, as it is tilted at 59 degrees from the planet’s rotation axis and offset from the planet’s center. This leads to a highly irregular and asymmetric magnetosphere, which differs from the more aligned magnetic fields of Earth or Jupiter. Uranus’s magnetic field flips and twists as the planet rotates, creating complex interactions with the solar wind.

            Exploration:
            - Uranus has only been visited by one spacecraft, Voyager 2, which flew by in 1986. During its flyby, Voyager 2 captured images and gathered data on the planet, its rings, and its moons. However, much about Uranus remains a mystery, as it has not had a dedicated mission focused solely on it since Voyager 2.

            Interesting Facts:
            - Extreme Seasons: Due to Uranus’s extreme axial tilt, its poles experience long periods of daylight and darkness. This results in some regions of the planet being in sunlight for 42 years, followed by 42 years of darkness.
            - Retrograde Rotation: Like Venus, Uranus rotates in the opposite direction (retrograde) to most planets in the Solar System, meaning it spins clockwise when viewed from above the Sun's north pole.
            - Coldest Planet: Despite being farther from the Sun, Neptune is warmer than Uranus, making Uranus the coldest planet in the Solar System.
            
            Potential for Life:
            - Uranus is unlikely to support life as we know it due to its frigid temperatures and lack of a solid surface. However, some of its moons, such as Ariel or Miranda, could potentially have environments where microbial life might exist beneath the surface, but this is purely speculative.

            Future Missions:
            - There has been significant interest in sending a dedicated mission to Uranus, especially after the successful exploration of other outer planets like Jupiter and Saturn. A mission to Uranus could provide much more detailed information about its rings, moons, atmosphere, and internal structure.
            """,
        
        
        "Neptune": """
            Neptune is the eighth and farthest-known planet from the Sun, making it a distant ice giant with some of the most dynamic weather in the Solar System. It shares similarities with Uranus but has unique features, including intense storms, strong winds, and an internal heat source.

            General Characteristics:
            - Type: Ice giant
            - Radius: Approximately 24,622 km (15,299 miles)
            - Diameter: 49,244 km (30,598 miles) — about 3.9 times the diameter of Earth
            - Mass: 1.02 × 10^26 kg (about 17 times Earth's mass)
            - Surface Area: 7.6 billion km²
            - Orbital Distance from the Sun: About 4.5 billion kilometers (30.07 Astronomical Units)
            - Rotation Period (Day): 16.11 Earth hours
            - Revolution Period (Year): 164.8 Earth years
            
            Discovery:
            - Neptune was the first planet located through mathematical predictions rather than direct observation. In 1846, scientists noticed irregularities in Uranus’s orbit and deduced the presence of a more distant planet influencing its motion. Using calculations by Urbain Le Verrier and John Couch Adams, Neptune was discovered by Johann Galle at the Berlin Observatory.

            Atmosphere:
            - Neptune’s atmosphere is composed primarily of hydrogen (80%), helium (19%), and methane (1.5%). Like Uranus, methane in its upper atmosphere absorbs red light, giving Neptune its vivid blue color.

            - Vivid Blue Color: Neptune’s deeper blue appearance, compared to Uranus’s paler blue-green, is likely due to an unknown component in addition to methane.
            - Storms and Winds: Neptune has some of the most extreme weather in the Solar System, with wind speeds reaching up to 2,100 km/h (1,300 mph), the fastest in the Solar System.
            - Great Dark Spot: Similar to Jupiter’s Great Red Spot, Neptune once had a massive storm called the Great Dark Spot, a giant storm system about the size of Earth, discovered by the Voyager 2 spacecraft in 1989. The storm was later observed to disappear, and new storm systems have appeared since.
            
            Structure:
            - Core: Neptune likely has a rocky core, made up of heavier elements like iron, nickel, and silicates.
            - Icy Mantle: Surrounding the core is an icy mantle of water, ammonia, and methane ices, which gives Neptune its classification as an ice giant. This layer is extremely thick and makes up the bulk of the planet's mass.
            - Atmosphere: The outer layer is a mixture of hydrogen, helium, and methane gas.
            
            Rings:
            - Neptune has a faint and thin system of five main rings made of dust and ice particles, named Galle, Le Verrier, Lassell, Arago, and Adams after astronomers who contributed to its discovery or study.

            - Clumpy Structure: Unlike Saturn’s well-defined rings, Neptune’s rings are clumpy and incomplete in certain areas, with arcs or dense regions within the rings.
            - Shepherd Moons: Some of Neptune’s moons, like Galatea, help shape and maintain the structure of the rings.
            
            Moons:
            - Neptune has 14 known moons, with Triton being by far the largest and most intriguing:
            - Triton: This is Neptune’s largest moon, and it orbits the planet in a retrograde orbit (opposite the planet’s rotation), suggesting that Triton was likely a captured object from the Kuiper Belt. Triton has a thin atmosphere and geysers that erupt nitrogen gas, making it one of the few moons in the Solar System with active geology.
            - Proteus: The second-largest moon, which has an irregular shape and is heavily cratered.
            - Nereid: Known for its highly eccentric orbit, one of the most elliptical of any moon in the Solar System.
            Other small moons: Neptune’s smaller moons, such as Larissa, Despina, and Galatea, orbit closer to the planet and likely contribute to shaping the rings.
            
            Magnetic Field:
            - Neptune’s magnetic field is tilted at about 47 degrees from its rotational axis and is offset from the planet’s center, similar to Uranus. This irregular magnetic field suggests that it may be generated by motion within the planet’s icy mantle rather than its core, as is the case with Earth and Jupiter. This creates complex and dynamic interactions with the solar wind.

            Temperature and Heat:
            Despite being so far from the Sun, Neptune has an internal heat source, radiating about 2.6 times more energy than it receives from the Sun. This heat is thought to drive the planet’s strong winds and dynamic weather systems.
            - Temperature: Temperatures in Neptune’s upper atmosphere can reach -214°C (-353°F). However, deeper inside the planet, the temperature rises significantly due to internal heat.
            
            Exploration:
            Like Uranus, Neptune has only been visited by one spacecraft, Voyager 2, which flew by the planet in 1989. Voyager 2’s flyby provided humanity with the first close-up images of Neptune, its moons, and its rings, revealing features like the Great Dark Spot and Triton’s geysers.

            Interesting Facts:
            - Dynamic Weather: Neptune is known for having some of the most extreme and dynamic weather in the Solar System. The planet’s strong winds and massive storms are driven by its internal heat rather than solar energy.
            - Great Dark Spot: The Great Dark Spot was a short-lived storm on Neptune’s surface, but new storms have been observed since, indicating that Neptune’s atmosphere is still very active.
            - Triton’s Retrograde Orbit: Triton’s unusual retrograde orbit and geological activity make it one of the most interesting moons in the Solar System. It is believed to have been captured by Neptune’s gravity, likely originating from the Kuiper Belt.
            
            Potential for Life:
            - While Neptune itself is unlikely to support life due to its cold temperatures and gaseous nature, Triton has sparked interest in the possibility of microbial life due to its subsurface ocean and geological activity. However, no evidence of life has been found so far.

            Future Exploration:
            - There is significant interest in returning to Neptune with a dedicated mission to study its atmosphere, rings, and moons, especially Triton, which may harbor an underground ocean. Proposed missions such as the Trident mission could explore Triton in more detail.
            """,
        
        "Sun":
        """
        The Sun is a massive star at the center of our solar system and is vital for life on Earth. Here are some key facts about the Sun:

        Composition and Structure:
        - Type: The Sun is a G-type main-sequence star (G dwarf) composed mainly of hydrogen (about 74%) and helium (about 24%), with trace amounts of heavier elements.
        
        Layers:
        - Core: The innermost part, where nuclear fusion occurs, converting hydrogen into helium and releasing energy.
        - Radiative Zone: Surrounding the core, energy produced in the core moves outward in the form of radiation.
        - Convective Zone: The outer layer where energy is transported by convection currents.
        
        Size and Mass:
        - The Sun has a diameter of about 1.4 million kilometers (about 864,000 miles), making it approximately 109 times wider than Earth.
        - It accounts for about 99.86% of the total mass of the solar system.
        
        Temperature:
        - The temperature at the core reaches about 15 million degrees Celsius (27 million degrees Fahrenheit), while the surface temperature is around 5,500 degrees Celsius (9,932 degrees Fahrenheit).
        
        Solar Activity:
        - The Sun undergoes an 11-year solar cycle, during which it experiences varying levels of solar activity, including sunspots, solar flares, and coronal mass ejections (CMEs).
        - Solar flares can release bursts of energy and radiation that can affect satellites and communication systems on Earth.
        
        Importance for Life:
        - The Sun provides light and heat, making Earth habitable. It drives photosynthesis in plants, producing oxygen and food for other life forms.
        - It influences Earth's climate and weather patterns.
        
        Distance from Earth:
        - The average distance from Earth to the Sun is about 93 million miles (150 million kilometers), commonly referred to as an astronomical unit (AU).
        - The Sun is not only a source of light and warmth but also a complex and dynamic astronomical body that continues to be the focus of scientific study and exploration.
        """
    ]
    
    /// The article for a body, in the current language, falling back to English
    /// when there's no translation.
    static func getDescription(for planet: String) -> String {
        if let translated = PlanetDetailsFa.description(for: planet) {
            return translated
        }
        return planetInfo[planet] ?? String(format: String(localized: "Information about %@ is not available.", bundle: Bundle.appLanguage), planet.localizedBodyName)
    }
}
