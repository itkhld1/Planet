//
//  QuizQuestions.swift
//  Planet
//
//  Created by itkhld on 11.12.2024.
//

import Foundation

/// The quiz bank for the current language, falling back to English.
///
/// The Persian bank keeps the same order and the same `correctIndex` values,
/// so the two are interchangeable.
var questions: [QuizQuestion] {
    AppLanguage.isPersian ? questionsFa : questionsEn
}

let questionsEn: [QuizQuestion] = [
    QuizQuestion(
        question: "Which planet is known for its extreme temperature changes?",
        options: ["Mercury", "Earth", "Jupiter", "Neptune"],
        correctIndex: 0,
        explanation: "With almost no atmosphere to trap heat, Mercury swings from 430°C in the day to -180°C at night."
    ),
    QuizQuestion(
        question: "Which planet has the largest volcano in the solar system?",
        options: ["Mars", "Venus", "Saturn", "Neptune"],
        correctIndex: 0,
        explanation: "Olympus Mons on Mars stands about 22 km high — roughly two and a half times the height of Everest."
    ),
    QuizQuestion(
        question: "Which planet has the fastest winds?",
        options: ["Jupiter", "Earth", "Neptune", "Venus"],
        correctIndex: 2,
        explanation: "Neptune's winds reach about 2,100 km/h, the fastest measured anywhere in the Solar System."
    ),
    QuizQuestion(
        question: "Which planet has a storm called the Great Red Spot?",
        options: ["Earth", "Mars", "Saturn", "Jupiter"],
        correctIndex: 3,
        explanation: "The Great Red Spot is a storm bigger than Earth that has been raging for at least 400 years."
    ),
    QuizQuestion(
        question: "Which planet has a day longer than its year?",
        options: ["Venus", "Mercury", "Neptune", "Earth"],
        correctIndex: 0,
        explanation: "Venus turns so slowly that one rotation takes 243 Earth days, while one orbit takes only 225."
    ),
    QuizQuestion(
        question: "What is the largest planet in our solar system?",
        options: ["Mars", "Earth", "Jupiter", "Saturn"],
        correctIndex: 2,
        explanation: "Jupiter is about 11 times Earth's diameter and 318 times its mass — more massive than all other planets combined."
    ),
    QuizQuestion(
        question: "Which planet is known as the Red Planet?",
        options: ["Venus", "Mars", "Mercury", "Jupiter"],
        correctIndex: 1,
        explanation: "Iron oxide (rust) in the Martian soil gives the planet its famous reddish colour."
    ),
    QuizQuestion(
        question: "What is the main component of the Sun?",
        options: ["Helium", "Oxygen", "Hydrogen", "Carbon"],
        correctIndex: 2,
        explanation: "The Sun is roughly 74% hydrogen, which it fuses into helium in its core to produce energy."
    ),
    QuizQuestion(
        question: "Which planet has the most rings?",
        options: ["Jupiter", "Saturn", "Uranus", "Neptune"],
        correctIndex: 1,
        explanation: "Saturn's ring system is by far the largest and brightest, divided into sections labelled A to G."
    ),
    QuizQuestion(
        question: "What is the hottest planet in our solar system?",
        options: ["Mercury", "Venus", "Mars", "Earth"],
        correctIndex: 1,
        explanation: "Venus averages about 465°C — hotter than Mercury — because its thick CO2 atmosphere traps heat."
    ),
    QuizQuestion(
        question: "Which planet is the closest to the Sun?",
        options: ["Earth", "Venus", "Mercury", "Mars"],
        correctIndex: 2,
        explanation: "Mercury orbits at about 57.9 million km from the Sun, closer than any other planet."
    ),
    QuizQuestion(
        question: "What is the name of Earth's largest moon?",
        options: ["Titan", "Europa", "Ganymede", "Moon"],
        correctIndex: 3,
        explanation: "Earth has just one natural satellite, the Moon, which is the fifth-largest moon in the Solar System."
    ),
    QuizQuestion(
        question: "What is the primary gas in the atmosphere of Neptune?",
        options: ["Methane", "Hydrogen", "Nitrogen", "Oxygen"],
        correctIndex: 0,
        explanation: "Methane in Neptune's upper atmosphere absorbs red light, which is what makes the planet look blue."
    ),
    QuizQuestion(
        question: "Which planet is known for having the longest day?",
        options: ["Neptune", "Earth", "Mercury", "Mars"],
        correctIndex: 2,
        explanation: "Mercury's slow spin means about 176 Earth days pass between one sunrise and the next."
    ),
    QuizQuestion(
        question: "Which planet has a tilted axis that causes extreme seasons?",
        options: ["Uranus", "Neptune", "Earth", "Mars"],
        correctIndex: 0,
        explanation: "Uranus is tilted about 98 degrees, so it rolls on its side and its poles get 42 years of sunlight at a time."
    ),
    QuizQuestion(
        question: "What is the main source of light for Earth?",
        options: ["Moon", "Sun", "Stars", "Planets"],
        correctIndex: 1,
        explanation: "Sunlight drives Earth's climate, weather and photosynthesis — nearly all life depends on it."
    ),
    QuizQuestion(
        question: "What is the second planet from the Sun?",
        options: ["Earth", "Venus", "Mars", "Mercury"],
        correctIndex: 1,
        explanation: "The order from the Sun is Mercury, Venus, Earth, Mars — so Venus is second."
    ),
    QuizQuestion(
        question: "Which planet is known for its beautiful blue color?",
        options: ["Earth", "Uranus", "Neptune", "Mars"],
        correctIndex: 2,
        explanation: "Methane in Neptune's atmosphere absorbs red light, leaving a vivid blue colour."
    ),
    QuizQuestion(
        question: "What phenomenon occurs when the Moon passes between the Earth and the Sun?",
        options: ["Lunar Eclipse", "Solar Eclipse", "Planetary Transit", "Supermoon"],
        correctIndex: 1,
        explanation: "In a solar eclipse the Moon passes between Earth and the Sun, blocking the Sun from view."
    ),
    QuizQuestion(
        question: "Which celestial body is considered a dwarf planet?",
        options: ["Pluto", "Mars", "Jupiter", "Venus"],
        correctIndex: 0,
        explanation: "Pluto was reclassified as a dwarf planet in 2006 because it has not cleared its orbit of other objects."
    ),
    QuizQuestion(
        question: "What is the main characteristic of a comet?",
        options: ["It is made of gas", "It has a tail", "It is larger than asteroids", "It is always visible"],
        correctIndex: 1,
        explanation: "A comet's tail forms when the Sun's heat vaporises its ice, blowing gas and dust into a long trail."
    ),
    QuizQuestion(
        question: "Which planet has the strongest gravity?",
        options: ["Earth", "Jupiter", "Saturn", "Neptune"],
        correctIndex: 1,
        explanation: "Jupiter is the most massive planet, so it has the strongest surface gravity — about 2.3 times Earth's."
    ),
    QuizQuestion(
        question: "What is the smallest planet in our solar system?",
        options: ["Venus", "Mercury", "Mars", "Earth"],
        correctIndex: 1,
        explanation: "Mercury's diameter is just 4,880 km, making it the smallest planet in the Solar System."
    ),
    QuizQuestion(
        question: "Which planet is known for its icy surface and potential for having water?",
        options: ["Europa", "Mars", "Venus", "Ganymede"],
        correctIndex: 0,
        explanation: "Europa's icy crust hides a subsurface ocean, making it a prime target in the search for life."
    ),
    QuizQuestion(
        question: "Which gas giant is known for its moon Titan?",
        options: ["Saturn", "Jupiter", "Neptune", "Uranus"],
        correctIndex: 0,
        explanation: "Titan is Saturn's largest moon and the only moon with a thick atmosphere."
    ),
    QuizQuestion(
        question: "What are the small rocky bodies mostly found between Mars and Jupiter called?",
        options: ["Asteroids", "Comets", "Meteors", "Planetoids"],
        correctIndex: 0,
        explanation: "The asteroid belt between Mars and Jupiter holds millions of rocky bodies left over from planet formation."
    ),
    QuizQuestion(
        question: "Which planet's surface temperature can exceed 400°C during the day?",
        options: ["Mercury", "Venus", "Earth", "Mars"],
        correctIndex: 0,
        explanation: "Mercury's daytime temperature can reach 430°C because it is closest to the Sun and has no real atmosphere."
    ),
    QuizQuestion(
        question: "What is the name of the largest moon of Saturn?",
        options: ["Ganymede", "Titan", "Europa", "Callisto"],
        correctIndex: 1,
        explanation: "Titan is Saturn's largest moon and the second-largest in the Solar System — bigger than Mercury."
    ),
    QuizQuestion(
        question: "Which planet has a surface covered with iron oxide, giving it a reddish appearance?",
        options: ["Mars", "Venus", "Mercury", "Earth"],
        correctIndex: 0,
        explanation: "Iron oxide, the same compound as rust, coats the Martian surface and dust."
    ),
    QuizQuestion(
        question: "Which planet is sometimes referred to as Earth's twin?",
        options: ["Mars", "Venus", "Jupiter", "Mercury"],
        correctIndex: 1,
        explanation: "Venus is about 95% of Earth's diameter and 81.5% of its mass, though its environment is nothing like ours."
    ),
    QuizQuestion(
        question: "What is the most abundant gas in Earth's atmosphere?",
        options: ["Oxygen", "Nitrogen", "Carbon Dioxide", "Hydrogen"],
        correctIndex: 1,
        explanation: "Earth's air is about 78% nitrogen, with 21% oxygen and 1% other gases."
    ),
    QuizQuestion(
        question: "What is the name of the boundary where the solar wind meets the interstellar medium?",
        options: ["Heliosphere", "Kuiper Belt", "Oort Cloud", "Heliopause"],
        correctIndex: 3,
        explanation: "The heliopause is where the solar wind is finally stopped by the interstellar medium."
    ),
    QuizQuestion(
        question: "Which planet is known as the Morning Star or Evening Star?",
        options: ["Venus", "Mars", "Mercury", "Jupiter"],
        correctIndex: 0,
        explanation: "Venus is so bright that it is often the first 'star' visible at dusk or the last at dawn."
    ),
    QuizQuestion(
        question: "Which dwarf planet is located in the asteroid belt?",
        options: ["Ceres", "Pluto", "Eris", "Makemake"],
        correctIndex: 0,
        explanation: "Ceres is the largest object in the asteroid belt and the only dwarf planet found there."
    ),
    QuizQuestion(
        question: "Which planet has a day that lasts about 10 hours?",
        options: ["Earth", "Jupiter", "Mars", "Neptune"],
        correctIndex: 1,
        explanation: "Jupiter spins once every 9.93 hours — the fastest rotation of any planet."
    ),
    QuizQuestion(
        question: "What is the approximate age of the solar system?",
        options: ["4.6 billion years", "2 billion years", "6 billion years", "5.5 billion years"],
        correctIndex: 0,
        explanation: "The Sun and planets formed from the same collapsing cloud of gas and dust about 4.6 billion years ago."
    ),
    QuizQuestion(
        question: "Which planet has the most moons?",
        options: ["Saturn", "Jupiter", "Neptune", "Uranus"],
        correctIndex: 0,
        explanation: "Saturn has 146 confirmed moons as of 2024, more than any other planet."
    ),
    QuizQuestion(
        question: "What is the outermost layer of the Sun called?",
        options: ["Chromosphere", "Corona", "Photosphere", "Core"],
        correctIndex: 1,
        explanation: "The corona is the Sun's outer atmosphere, visible as a halo during a total solar eclipse."
    ),
    QuizQuestion(
        question: "What is the name of the dark spots on the Sun caused by magnetic activity?",
        options: ["Sunspots", "Solar Flares", "Prominences", "Auroras"],
        correctIndex: 0,
        explanation: "Sunspots are cooler, darker regions where the Sun's magnetic field is especially strong."
    ),
    QuizQuestion(
        question: "Which planet's atmosphere is composed mostly of carbon dioxide and nitrogen?",
        options: ["Mars", "Venus", "Earth", "Neptune"],
        correctIndex: 1,
        explanation: "Venus's atmosphere is about 96.5% carbon dioxide with roughly 3.5% nitrogen."
    ),
    QuizQuestion(
        question: "Which celestial event occurs when Earth passes through the debris left by a comet?",
        options: ["Meteor Shower", "Eclipse", "Aurora", "Supernova"],
        correctIndex: 0,
        explanation: "When Earth crosses a comet's dusty trail, the debris burns up as a meteor shower."
    ),
    QuizQuestion(
        question: "Which planet has the Great Dark Spot, a storm similar to Jupiter's Great Red Spot?",
        options: ["Neptune", "Uranus", "Saturn", "Jupiter"],
        correctIndex: 0,
        explanation: "Voyager 2 photographed Neptune's Great Dark Spot in 1989; the storm has since disappeared."
    ),
    QuizQuestion(
        question: "Which planet has a moon named Triton?",
        options: ["Neptune", "Saturn", "Uranus", "Jupiter"],
        correctIndex: 0,
        explanation: "Triton is Neptune's largest moon and orbits backwards, suggesting Neptune captured it."
    ),
    QuizQuestion(
        question: "What is the region of the solar system beyond Neptune called?",
        options: ["Kuiper Belt", "Oort Cloud", "Asteroid Belt", "Heliosphere"],
        correctIndex: 0,
        explanation: "The Kuiper Belt is a ring of icy bodies beyond Neptune's orbit, including Pluto."
    ),
    QuizQuestion(
        question: "Which planet is known for its hexagonal storm at the north pole?",
        options: ["Saturn", "Jupiter", "Neptune", "Uranus"],
        correctIndex: 0,
        explanation: "Saturn's north pole has a strange six-sided jet stream that scientists still do not fully understand."
    ),
    QuizQuestion(
        question: "Which moon is thought to have a subsurface ocean of water beneath its icy crust?",
        options: ["Europa", "Titan", "Ganymede", "Callisto"],
        correctIndex: 0,
        explanation: "Europa's smooth ice shell likely covers a global ocean kept liquid by tidal heating."
    ),
    QuizQuestion(
        question: "What is the term for a rocky body that enters Earth's atmosphere and burns up?",
        options: ["Meteor", "Asteroid", "Comet", "Meteorite"],
        correctIndex: 0,
        explanation: "A meteor is the streak of light made as a space rock burns up in the atmosphere."
    ),
    QuizQuestion(
        question: "What planet is famous for its Great White Spot, a periodic storm system?",
        options: ["Saturn", "Jupiter", "Neptune", "Uranus"],
        correctIndex: 0,
        explanation: "Saturn's Great White Spot is a huge storm that erupts roughly every 30 Earth years."
    ),
    QuizQuestion(
        question: "Which planet is closest in size to Earth?",
        options: ["Venus", "Mars", "Mercury", "Neptune"],
        correctIndex: 0,
        explanation: "Venus is about 95% of Earth's diameter, closer in size to Earth than any other planet."
    ),
    QuizQuestion(
        question: "What is the name of the mission that brought humans to the Moon?",
        options: ["Apollo", "Voyager", "Pioneer", "Gemini"],
        correctIndex: 0,
        explanation: "NASA's Apollo programme landed astronauts on the Moon between 1969 and 1972."
    ),
    QuizQuestion(
        question: "What are the icy bodies with tails that orbit the Sun called?",
        options: ["Comets", "Asteroids", "Meteoroids", "Planetoids"],
        correctIndex: 0,
        explanation: "Comets are icy bodies that grow glowing tails of gas and dust when they near the Sun."
    ),
    QuizQuestion(
        question: "What is the second-largest moon in the solar system?",
        options: ["Ganymede", "Titan", "Europa", "Callisto"],
        correctIndex: 1,
        explanation: "Titan is second only to Jupiter's Ganymede, and is larger than the planet Mercury."
    ),
    QuizQuestion(
        question: "Which planet has the coldest surface temperature?",
        options: ["Neptune", "Uranus", "Pluto", "Saturn"],
        correctIndex: 1,
        explanation: "Uranus drops to about -224°C — colder than Neptune, even though Neptune is farther out."
    ),
    QuizQuestion(
        question: "Which celestial body is the main source of gravitational force in the solar system?",
        options: ["Sun", "Earth", "Jupiter", "Saturn"],
        correctIndex: 0,
        explanation: "The Sun holds about 99.86% of the Solar System's mass, so its gravity governs every orbit."
    ),
    QuizQuestion(
        question: "What is the approximate diameter of Earth?",
        options: ["12,742 km", "6,371 km", "10,742 km", "15,742 km"],
        correctIndex: 0,
        explanation: "Earth is about 12,742 km across, roughly 6,371 km in radius."
    ),
    QuizQuestion(
        question: "Which planet has a moon with geysers that spray water into space?",
        options: ["Saturn", "Jupiter", "Neptune", "Uranus"],
        correctIndex: 0,
        explanation: "Saturn's moon Enceladus sprays water vapour and organic molecules from cracks near its south pole."
    ),
    QuizQuestion(
        question: "Which planet has the shortest orbital period around the Sun?",
        options: ["Mercury", "Venus", "Mars", "Earth"],
        correctIndex: 0,
        explanation: "Mercury completes an orbit in just 88 Earth days — the shortest year of any planet."
    ),
    QuizQuestion(
        question: "What are the bright streaks of light caused by meteoroids burning up in Earth's atmosphere called?",
        options: ["Shooting Stars", "Asteroids", "Comets", "Auroras"],
        correctIndex: 0,
        explanation: "Shooting stars are meteors: tiny meteoroids burning up from friction with the air."
    ),
    QuizQuestion(
        question: "What is the main component of Venus's atmosphere?",
        options: ["Carbon Dioxide", "Oxygen", "Nitrogen", "Hydrogen"],
        correctIndex: 0,
        explanation: "Venus's atmosphere is about 96.5% carbon dioxide, which drives its runaway greenhouse effect."
    ),
    QuizQuestion(
        question: "Which planet has the highest mountain in the solar system?",
        options: ["Mars", "Earth", "Venus", "Mercury"],
        correctIndex: 0,
        explanation: "Olympus Mons on Mars rises about 22 km, the tallest mountain on any planet."
    ),
    QuizQuestion(
        question: "What is the name of the largest volcano in the solar system?",
        options: ["Olympus Mons", "Mauna Kea", "Vesuvius", "Tharsis"],
        correctIndex: 0,
        explanation: "Olympus Mons is a Martian shield volcano roughly 22 km tall and 600 km wide."
    ),
    QuizQuestion(
        question: "What is the densest planet in the solar system?",
        options: ["Earth", "Jupiter", "Saturn", "Venus"],
        correctIndex: 0,
        explanation: "Earth's iron core makes it the densest planet at about 5.5 g/cm³."
    ),
    QuizQuestion(
        question: "What is the term for a planet outside our solar system?",
        options: ["Exoplanet", "Dwarf Planet", "Rogue Planet", "Minor Planet"],
        correctIndex: 0,
        explanation: "An exoplanet is any planet orbiting a star other than our Sun; thousands are now known."
    ),
    QuizQuestion(
        question: "Which planet is the farthest from the Sun?",
        options: ["Neptune", "Uranus", "Pluto", "Saturn"],
        correctIndex: 0,
        explanation: "Neptune orbits about 4.5 billion km out — the farthest true planet from the Sun."
    ),
    QuizQuestion(
        question: "What is the term for the boundary around a black hole from which nothing can escape?",
        options: ["Event Horizon", "Singularity", "Accretion Disk", "Schwarzschild Radius"],
        correctIndex: 0,
        explanation: "Past the event horizon, escaping would require travelling faster than light, so nothing gets out."
    ),
    QuizQuestion(
        question: "Which planet has rings made mostly of ice and rock particles?",
        options: ["Saturn", "Jupiter", "Uranus", "Neptune"],
        correctIndex: 0,
        explanation: "Saturn's rings are mostly water ice with some dust and rock, and only about 10 metres thick."
    ),
    QuizQuestion(
        question: "Which moon is the largest in the solar system?",
        options: ["Ganymede", "Titan", "Europa", "Callisto"],
        correctIndex: 0,
        explanation: "Ganymede, a moon of Jupiter, is larger than Mercury and the only moon with its own magnetic field."
    ),
    QuizQuestion(
        question: "What is the name of the spacecraft that sent back images of Pluto in 2015?",
        options: ["New Horizons", "Voyager 1", "Cassini", "Pioneer 10"],
        correctIndex: 0,
        explanation: "New Horizons flew past Pluto in July 2015, returning the first close-up images ever taken."
    ),
    QuizQuestion(
        question: "What is the term for the area of the solar system dominated by the Sun’s gravity?",
        options: ["Heliosphere", "Magnetosphere", "Asteroid Belt", "Oort Cloud"],
        correctIndex: 0,
        explanation: "The heliosphere is the vast bubble carved out by the solar wind around the Sun."
    ),
    QuizQuestion(
        question: "What is the term for a small body in space that orbits the Sun and is mostly composed of rock and metal?",
        options: ["Asteroid", "Comet", "Meteor", "Moon"],
        correctIndex: 0,
        explanation: "Asteroids are rocky, metallic leftovers from the Solar System's formation."
    ),

    // MARK: - Mercury

    QuizQuestion(
        question: "Roughly how long is a year on Mercury?",
        options: ["88 Earth days", "225 Earth days", "59 Earth days", "687 Earth days"],
        correctIndex: 0,
        explanation: "Mercury orbits the Sun in just 88 Earth days, the shortest year of any planet."
    ),
    QuizQuestion(
        question: "Mercury's thin atmosphere is more accurately called what?",
        options: ["An exosphere", "A stratosphere", "A troposphere", "A magnetosphere"],
        correctIndex: 0,
        explanation: "Mercury's atmosphere is so thin it is called an exosphere — atoms knocked off the surface by the solar wind."
    ),
    QuizQuestion(
        question: "What is the name of one of the largest impact basins on Mercury?",
        options: ["Caloris Basin", "Hellas Basin", "Cassini Division", "Valles Marineris"],
        correctIndex: 0,
        explanation: "The Caloris Basin is one of the largest impact craters in the Solar System."
    ),
    QuizQuestion(
        question: "About how much of Mercury's radius is taken up by its iron core?",
        options: ["85%", "25%", "50%", "10%"],
        correctIndex: 0,
        explanation: "Mercury's iron core spans about 85% of its radius, proportionally the largest of any planet."
    ),
    QuizQuestion(
        question: "Which spacecraft was the first to orbit Mercury?",
        options: ["MESSENGER", "Mariner 10", "BepiColombo", "Juno"],
        correctIndex: 0,
        explanation: "MESSENGER orbited Mercury from 2011 to 2015; Mariner 10 only flew past it."
    ),
    QuizQuestion(
        question: "Which planet travels fastest around the Sun, at about 47 km/s?",
        options: ["Mercury", "Venus", "Earth", "Jupiter"],
        correctIndex: 0,
        explanation: "Being closest to the Sun, Mercury must move fastest — about 47 km/s — to stay in orbit."
    ),
    QuizQuestion(
        question: "How many moons does Mercury have?",
        options: ["None", "One", "Two", "Five"],
        correctIndex: 0,
        explanation: "Mercury has no moons and no rings, much like Venus."
    ),

    // MARK: - Venus

    QuizQuestion(
        question: "What are the thick clouds covering Venus made of?",
        options: ["Sulfuric acid", "Water ice", "Ammonia", "Methane"],
        correctIndex: 0,
        explanation: "Venus's clouds are droplets of sulfuric acid, making the atmosphere highly toxic."
    ),
    QuizQuestion(
        question: "The atmospheric pressure on Venus is about how many times Earth's?",
        options: ["92 times", "5 times", "20 times", "300 times"],
        correctIndex: 0,
        explanation: "Venus's surface pressure is about 92 times Earth's — like being 900 metres underwater."
    ),
    QuizQuestion(
        question: "What is the highest mountain on Venus called?",
        options: ["Maxwell Montes", "Olympus Mons", "Mauna Kea", "Tharsis Rise"],
        correctIndex: 0,
        explanation: "Maxwell Montes is the highest point on Venus, rising above the surrounding plains."
    ),
    QuizQuestion(
        question: "Why is Venus hotter than Mercury despite being farther from the Sun?",
        options: ["A runaway greenhouse effect", "It is closer to Jupiter", "It spins very fast", "It has an internal heat source"],
        correctIndex: 0,
        explanation: "Venus's thick CO2 atmosphere traps heat so effectively that it beats Mercury despite being farther away."
    ),
    QuizQuestion(
        question: "On Venus, the Sun rises in the west because the planet has what kind of rotation?",
        options: ["Retrograde", "Synchronous", "Elliptical", "Resonant"],
        correctIndex: 0,
        explanation: "Venus rotates backwards compared to most planets, so the Sun appears to rise in the west."
    ),
    QuizQuestion(
        question: "Which mission mapped Venus's surface using radar?",
        options: ["Magellan", "Cassini", "Voyager 2", "Galileo"],
        correctIndex: 0,
        explanation: "Magellan mapped Venus with radar from 1990 to 1994, since its clouds hide the surface from view."
    ),
    QuizQuestion(
        question: "Why does Venus have almost no seasons?",
        options: ["Its axis is tilted only about 3 degrees", "It has no atmosphere", "It orbits too quickly", "It is tidally locked"],
        correctIndex: 0,
        explanation: "With a tilt of only about 3 degrees, Venus has almost no seasonal variation."
    ),

    // MARK: - Earth

    QuizQuestion(
        question: "About how much of Earth's surface is covered by water?",
        options: ["71%", "50%", "35%", "90%"],
        correctIndex: 0,
        explanation: "About 71% of Earth's surface is ocean, which is why it looks blue from space."
    ),
    QuizQuestion(
        question: "Earth's axis is tilted at about how many degrees, causing the seasons?",
        options: ["23.5 degrees", "3 degrees", "45 degrees", "98 degrees"],
        correctIndex: 0,
        explanation: "Earth's 23.5-degree tilt means each hemisphere leans toward the Sun for part of the year."
    ),
    QuizQuestion(
        question: "What generates Earth's protective magnetic field?",
        options: ["Its molten iron outer core", "Its atmosphere", "The Moon's gravity", "Its tectonic plates"],
        correctIndex: 0,
        explanation: "Motion in Earth's molten iron outer core generates the magnetic field that deflects solar radiation."
    ),
    QuizQuestion(
        question: "Where does the Moon rank among the moons of the Solar System by size?",
        options: ["Fifth-largest", "Largest", "Second-largest", "Tenth-largest"],
        correctIndex: 0,
        explanation: "Earth's Moon is the fifth-largest moon in the Solar System, after Ganymede, Titan, Callisto and Io."
    ),
    QuizQuestion(
        question: "How long does Earth take to orbit the Sun?",
        options: ["365.25 days", "24 hours", "687 days", "225 days"],
        correctIndex: 0,
        explanation: "Earth takes 365.25 days to orbit the Sun — the extra quarter day is why we add a leap day."
    ),

    // MARK: - Mars

    QuizQuestion(
        question: "How tall is Olympus Mons, the largest volcano in the Solar System?",
        options: ["About 22 km", "About 9 km", "About 50 km", "About 4 km"],
        correctIndex: 0,
        explanation: "Olympus Mons is about 22 km tall, roughly two and a half times the height of Mount Everest."
    ),
    QuizQuestion(
        question: "What is the name of the huge canyon system on Mars that stretches over 4,000 km?",
        options: ["Valles Marineris", "Grand Canyon", "Caloris Basin", "Cassini Division"],
        correctIndex: 0,
        explanation: "Valles Marineris runs over 4,000 km across Mars — long enough to span the United States."
    ),
    QuizQuestion(
        question: "What are the names of Mars's two moons?",
        options: ["Phobos and Deimos", "Titan and Rhea", "Io and Europa", "Triton and Nereid"],
        correctIndex: 0,
        explanation: "Phobos and Deimos are small, irregular moons, probably asteroids captured by Mars."
    ),
    QuizQuestion(
        question: "What is a day on Mars called?",
        options: ["A sol", "A lune", "A mar", "A cycle"],
        correctIndex: 0,
        explanation: "A Martian day is called a sol and lasts 24 hours and 39 minutes, just longer than Earth's."
    ),
    QuizQuestion(
        question: "How long is a year on Mars?",
        options: ["687 Earth days", "365 Earth days", "88 Earth days", "225 Earth days"],
        correctIndex: 0,
        explanation: "Mars takes 687 Earth days to orbit the Sun, almost twice as long as Earth."
    ),
    QuizQuestion(
        question: "What was the name of the first helicopter to fly on Mars?",
        options: ["Ingenuity", "Perseverance", "Curiosity", "Opportunity"],
        correctIndex: 0,
        explanation: "Ingenuity arrived with the Perseverance rover in 2021 and made the first powered flight on another planet."
    ),
    QuizQuestion(
        question: "Mars's polar ice caps are made of water ice and what else?",
        options: ["Frozen carbon dioxide", "Frozen methane", "Frozen ammonia", "Frozen nitrogen"],
        correctIndex: 0,
        explanation: "Mars's polar caps are a mix of water ice and frozen carbon dioxide, or dry ice."
    ),
    QuizQuestion(
        question: "Which Mars rover is exploring Gale Crater?",
        options: ["Curiosity", "Spirit", "Perseverance", "Opportunity"],
        correctIndex: 0,
        explanation: "Curiosity landed in Gale Crater in 2012 and has found signs of ancient microbial conditions."
    ),

    // MARK: - Jupiter

    QuizQuestion(
        question: "How long is a day on Jupiter?",
        options: ["About 10 hours", "About 24 hours", "About 17 hours", "About 243 days"],
        correctIndex: 0,
        explanation: "Jupiter rotates once every 9.93 hours, the fastest of any planet, which makes it bulge at the equator."
    ),
    QuizQuestion(
        question: "Jupiter is about how many times the mass of Earth?",
        options: ["318 times", "95 times", "11 times", "1,000 times"],
        correctIndex: 0,
        explanation: "Jupiter's mass is about 318 times Earth's, though it is made mostly of hydrogen and helium."
    ),
    QuizQuestion(
        question: "Who discovered Jupiter's four largest moons in 1610?",
        options: ["Galileo Galilei", "Johann Galle", "Urbain Le Verrier", "William Herschel"],
        correctIndex: 0,
        explanation: "Galileo spotted Io, Europa, Ganymede and Callisto in 1610 — they are now called the Galilean moons."
    ),
    QuizQuestion(
        question: "Which moon of Jupiter is the most volcanically active body in the Solar System?",
        options: ["Io", "Europa", "Ganymede", "Callisto"],
        correctIndex: 0,
        explanation: "Io is covered in active volcanoes and sulfur, heated by Jupiter's immense tidal forces."
    ),
    QuizQuestion(
        question: "Which is the only moon known to have its own magnetic field?",
        options: ["Ganymede", "Titan", "Europa", "Triton"],
        correctIndex: 0,
        explanation: "Ganymede is the only moon known to generate its own magnetic field."
    ),
    QuizQuestion(
        question: "What exotic form of hydrogen inside Jupiter generates its magnetic field?",
        options: ["Metallic hydrogen", "Frozen hydrogen", "Heavy hydrogen", "Hydrogen ice"],
        correctIndex: 0,
        explanation: "Under enormous pressure, hydrogen inside Jupiter behaves like a liquid metal and conducts electricity."
    ),
    QuizQuestion(
        question: "Which spacecraft is currently orbiting Jupiter?",
        options: ["Juno", "Cassini", "Galileo", "New Horizons"],
        correctIndex: 0,
        explanation: "Juno has been orbiting Jupiter since 2016, studying its atmosphere, gravity and magnetic field."
    ),
    QuizQuestion(
        question: "Roughly how long has Jupiter's Great Red Spot been raging?",
        options: ["At least 400 years", "About 50 years", "About 10 years", "About 5,000 years"],
        correctIndex: 0,
        explanation: "The Great Red Spot has been observed for at least 400 years, with winds over 400 km/h."
    ),

    // MARK: - Saturn

    QuizQuestion(
        question: "Saturn is the least dense planet — what would it do in a large enough ocean?",
        options: ["Float", "Sink", "Dissolve", "Boil"],
        correctIndex: 0,
        explanation: "Saturn's average density is lower than water's, so it would float given a big enough ocean."
    ),
    QuizQuestion(
        question: "What is the large gap between Saturn's A and B rings called?",
        options: ["The Cassini Division", "The Huygens Gap", "The Galle Gap", "The Encke Belt"],
        correctIndex: 0,
        explanation: "The Cassini Division is a wide gap separating Saturn's A and B rings."
    ),
    QuizQuestion(
        question: "Saturn's rings are made mostly of what material?",
        options: ["Water ice", "Iron dust", "Liquid methane", "Sulfur"],
        correctIndex: 0,
        explanation: "Saturn's rings are mostly water ice particles, ranging from micrometres to metres across."
    ),
    QuizQuestion(
        question: "Which moon has lakes of liquid methane and ethane on its surface?",
        options: ["Titan", "Enceladus", "Europa", "Mimas"],
        correctIndex: 0,
        explanation: "Titan is the only body besides Earth known to have stable liquid on its surface — lakes of methane and ethane."
    ),
    QuizQuestion(
        question: "Which icy moon of Saturn shoots geysers of water vapour from its south pole?",
        options: ["Enceladus", "Titan", "Rhea", "Iapetus"],
        correctIndex: 0,
        explanation: "Enceladus vents water vapour and organic molecules from its south pole, hinting at a subsurface ocean."
    ),
    QuizQuestion(
        question: "Which moon is nicknamed the \"Death Star moon\" because of its huge crater?",
        options: ["Mimas", "Iapetus", "Rhea", "Titan"],
        correctIndex: 0,
        explanation: "Mimas has a crater so large it resembles the Death Star from Star Wars."
    ),
    QuizQuestion(
        question: "Which probe landed on Titan in 2005?",
        options: ["Huygens", "Cassini", "Viking", "Philae"],
        correctIndex: 0,
        explanation: "The Huygens probe, carried by Cassini, landed on Titan in 2005 — the first landing in the outer Solar System."
    ),
    QuizQuestion(
        question: "How often does Saturn's \"Great White Spot\" storm roughly appear?",
        options: ["Every 30 Earth years", "Every year", "Every 400 years", "Every 5 Earth years"],
        correctIndex: 0,
        explanation: "Saturn's Great White Spot is a giant storm that erupts roughly every 30 Earth years."
    ),

    // MARK: - Uranus

    QuizQuestion(
        question: "How long does each pole of Uranus spend in continuous sunlight?",
        options: ["42 years", "6 months", "84 years", "11 years"],
        correctIndex: 0,
        explanation: "Uranus's 98-degree tilt gives each pole 42 years of sunlight followed by 42 years of darkness."
    ),
    QuizQuestion(
        question: "Which gas gives Uranus its blue-green colour?",
        options: ["Methane", "Helium", "Nitrogen", "Oxygen"],
        correctIndex: 0,
        explanation: "Methane in the upper atmosphere absorbs red light, leaving Uranus a pale blue-green."
    ),
    QuizQuestion(
        question: "What type of planet is Uranus classified as?",
        options: ["Ice giant", "Gas giant", "Terrestrial planet", "Dwarf planet"],
        correctIndex: 0,
        explanation: "Uranus is an ice giant: much of its mass is water, ammonia and methane ices rather than gas."
    ),
    QuizQuestion(
        question: "Uranus's moons are mostly named after characters from whose works?",
        options: ["Shakespeare", "Homer", "Tolkien", "Greek myths"],
        correctIndex: 0,
        explanation: "Uranus's moons are named for characters from Shakespeare and Alexander Pope."
    ),
    QuizQuestion(
        question: "Which is the largest moon of Uranus?",
        options: ["Titania", "Oberon", "Miranda", "Ariel"],
        correctIndex: 0,
        explanation: "Titania is the largest of Uranus's 27 known moons."
    ),
    QuizQuestion(
        question: "Which is the only spacecraft to have visited Uranus?",
        options: ["Voyager 2", "Voyager 1", "Cassini", "Juno"],
        correctIndex: 0,
        explanation: "Voyager 2 flew past Uranus in 1986 and remains the only spacecraft to have visited it."
    ),
    QuizQuestion(
        question: "How long is a year on Uranus?",
        options: ["84 Earth years", "29 Earth years", "165 Earth years", "12 Earth years"],
        correctIndex: 0,
        explanation: "Uranus takes 84 Earth years to orbit the Sun — a human lifetime is about one Uranian year."
    ),

    // MARK: - Neptune

    QuizQuestion(
        question: "What made Neptune's discovery unique?",
        options: ["It was predicted by mathematics before being seen", "It was found by accident", "It was seen by ancient astronomers", "It was discovered by a spacecraft"],
        correctIndex: 0,
        explanation: "Astronomers predicted Neptune from irregularities in Uranus's orbit, then found it almost exactly where the maths said."
    ),
    QuizQuestion(
        question: "In what year was Neptune discovered?",
        options: ["1846", "1781", "1930", "1610"],
        correctIndex: 0,
        explanation: "Johann Galle found Neptune in 1846, using calculations by Le Verrier and Adams."
    ),
    QuizQuestion(
        question: "How fast are Neptune's winds, the fastest in the Solar System?",
        options: ["About 2,100 km/h", "About 400 km/h", "About 360 km/h", "About 800 km/h"],
        correctIndex: 0,
        explanation: "Neptune's winds hit about 2,100 km/h, driven by its internal heat rather than sunlight."
    ),
    QuizQuestion(
        question: "Why does Triton's retrograde orbit suggest it was captured?",
        options: ["It orbits opposite to Neptune's rotation", "It orbits faster than Neptune spins", "It has no atmosphere", "It is perfectly circular"],
        correctIndex: 0,
        explanation: "Triton orbits opposite to Neptune's spin, which is why it is thought to be a captured Kuiper Belt object."
    ),
    QuizQuestion(
        question: "What gas erupts from Triton's geysers?",
        options: ["Nitrogen", "Oxygen", "Methane", "Carbon dioxide"],
        correctIndex: 0,
        explanation: "Triton's geysers erupt nitrogen gas, making it one of the few geologically active moons."
    ),
    QuizQuestion(
        question: "Neptune radiates about how much more energy than it receives from the Sun?",
        options: ["2.6 times", "Exactly the same", "10 times", "Half as much"],
        correctIndex: 0,
        explanation: "Neptune gives off about 2.6 times more energy than it receives, so it has an internal heat source."
    ),
    QuizQuestion(
        question: "How long is a year on Neptune?",
        options: ["About 165 Earth years", "About 84 Earth years", "About 29 Earth years", "About 248 Earth years"],
        correctIndex: 0,
        explanation: "Neptune takes about 164.8 Earth years to orbit the Sun — it has completed only one orbit since its discovery."
    ),
    QuizQuestion(
        question: "Neptune's rings are named after astronomers — which is the outermost main ring?",
        options: ["Adams", "Galle", "Le Verrier", "Lassell"],
        correctIndex: 0,
        explanation: "Neptune's five main rings are named Galle, Le Verrier, Lassell, Arago and Adams; Adams is outermost."
    ),

    // MARK: - The Sun

    QuizQuestion(
        question: "What type of star is the Sun?",
        options: ["A G-type main-sequence star", "A red giant", "A white dwarf", "A neutron star"],
        correctIndex: 0,
        explanation: "The Sun is a G-type main-sequence star, often called a yellow dwarf."
    ),
    QuizQuestion(
        question: "How hot is the Sun's core?",
        options: ["About 15 million °C", "About 5,500 °C", "About 1 million °C", "About 100,000 °C"],
        correctIndex: 0,
        explanation: "The Sun's core reaches about 15 million °C, hot enough to fuse hydrogen into helium."
    ),
    QuizQuestion(
        question: "The Sun is roughly how many times wider than Earth?",
        options: ["109 times", "11 times", "1,000 times", "50 times"],
        correctIndex: 0,
        explanation: "The Sun's diameter is about 1.4 million km, roughly 109 times Earth's."
    ),
    QuizQuestion(
        question: "About what share of the Solar System's total mass is the Sun?",
        options: ["99.86%", "75%", "50%", "90%"],
        correctIndex: 0,
        explanation: "The Sun contains about 99.86% of all the mass in the Solar System."
    ),
    QuizQuestion(
        question: "How long is the Sun's solar cycle?",
        options: ["11 years", "1 year", "25 years", "100 years"],
        correctIndex: 0,
        explanation: "Solar activity rises and falls on an 11-year cycle, with sunspots and flares peaking at the maximum."
    ),
    QuizQuestion(
        question: "In which layer of the Sun does nuclear fusion take place?",
        options: ["The core", "The corona", "The photosphere", "The convective zone"],
        correctIndex: 0,
        explanation: "Fusion only happens in the core, where pressure and temperature are extreme enough."
    ),
    QuizQuestion(
        question: "What is the average distance from Earth to the Sun called?",
        options: ["An astronomical unit", "A light year", "A parsec", "A solar mile"],
        correctIndex: 0,
        explanation: "One astronomical unit (AU) is about 150 million km, the average Earth-Sun distance."
    ),
    QuizQuestion(
        question: "How long does the Moon take to orbit Earth?",
        options: ["About 7 days", "About 27 days", "About 90 days", "About 365 days"],
        correctIndex: 1,
        explanation: "The Moon completes one orbit in about 27.3 days; from one full moon to the next takes about 29.5 days, because Earth moves along its own orbit meanwhile."
    ),
    QuizQuestion(
        question: "Why do we always see the same side of the Moon?",
        options: ["It spins once for every orbit (tidal locking)", "It doesn't spin at all", "Earth's shadow hides the other side", "The far side is too dark to see"],
        correctIndex: 0,
        explanation: "Earth's gravity slowed the Moon's spin until one rotation takes exactly one orbit, so the same face always points at us."
    ),
    QuizQuestion(
        question: "What mainly causes ocean tides on Earth?",
        options: ["Wind", "Earth's rotation alone", "Underwater volcanoes", "The Moon's gravity"],
        correctIndex: 3,
        explanation: "The Moon's gravity pulls the oceans into two bulges; the Sun adds a smaller pull, making extra-high tides at new and full moon."
    ),
    QuizQuestion(
        question: "About how far away is the Moon?",
        options: ["38,000 km", "3.8 million km", "384,000 km", "150 million km"],
        correctIndex: 2,
        explanation: "On average the Moon is about 384,400 km away; you could line up about 30 Earths in that gap."
    ),
    QuizQuestion(
        question: "What happens during a lunar eclipse?",
        options: ["The Moon blocks the Sun", "Earth's shadow falls on the Moon", "The Moon passes behind the Sun", "Clouds cover the Moon"],
        correctIndex: 1,
        explanation: "When Earth sits exactly between the Sun and the Moon, its shadow falls on the Moon, often turning it a coppery red."
    ),
    QuizQuestion(
        question: "How long does sunlight take to reach Earth?",
        options: ["About 8 minutes", "About 8 seconds", "About 1 hour", "About 1 day"],
        correctIndex: 0,
        explanation: "Light covers the 150 million km from the Sun in about 8 minutes 20 seconds, so we always see the Sun as it was a few minutes ago."
    ),
    QuizQuestion(
        question: "Who was the first person to walk on the Moon?",
        options: ["Buzz Aldrin", "Yuri Gagarin", "Michael Collins", "Neil Armstrong"],
        correctIndex: 3,
        explanation: "Neil Armstrong stepped onto the Moon on 20 July 1969 during Apollo 11, followed minutes later by Buzz Aldrin."
    ),
    QuizQuestion(
        question: "What are the dark, flat plains on the Moon called?",
        options: ["Craters", "Highlands", "Maria, or seas", "Rilles"],
        correctIndex: 2,
        explanation: "They're ancient lava flows. Early astronomers mistook them for seas, so they're called maria, Latin for seas."
    ),
    QuizQuestion(
        question: "The Moon is slowly drifting away from Earth. By how much each year?",
        options: ["About 3.8 m", "About 3.8 cm", "About 38 km", "It isn't moving away"],
        correctIndex: 1,
        explanation: "Tides pass energy to the Moon, pushing it about 3.8 cm farther away each year, roughly as fast as fingernails grow."
    ),
    QuizQuestion(
        question: "What causes the auroras, the northern and southern lights?",
        options: ["Charged particles from the Sun hitting the atmosphere", "Moonlight reflecting off polar ice", "Lightning high in the sky", "City lights bouncing off clouds"],
        correctIndex: 0,
        explanation: "Earth's magnetic field steers charged particles from the solar wind toward the poles, where they make the upper atmosphere glow."
    ),
    QuizQuestion(
        question: "What was the first artificial satellite?",
        options: ["Explorer 1", "Vostok 1", "Hubble", "Sputnik 1"],
        correctIndex: 3,
        explanation: "The Soviet Union launched Sputnik 1 on 4 October 1957, starting the Space Age."
    ),
    QuizQuestion(
        question: "Who was the first human in space?",
        options: ["Neil Armstrong", "Alan Shepard", "Yuri Gagarin", "Valentina Tereshkova"],
        correctIndex: 2,
        explanation: "Yuri Gagarin orbited Earth once aboard Vostok 1 on 12 April 1961; the flight lasted 108 minutes."
    ),
    QuizQuestion(
        question: "Who was the first woman in space?",
        options: ["Sally Ride", "Valentina Tereshkova", "Mae Jemison", "Peggy Whitson"],
        correctIndex: 1,
        explanation: "Valentina Tereshkova orbited Earth 48 times aboard Vostok 6 in June 1963."
    ),
    QuizQuestion(
        question: "Which spacecraft is the farthest human-made object from Earth?",
        options: ["Voyager 1", "Voyager 2", "New Horizons", "Pioneer 10"],
        correctIndex: 0,
        explanation: "Launched in 1977, Voyager 1 is more than 24 billion km away. It left the heliosphere in 2012 and is still sending data."
    ),
    QuizQuestion(
        question: "What do the Voyager probes carry in case aliens ever find them?",
        options: ["A map of every city on Earth", "Seeds of Earth's plants", "A copy of every book", "A golden record of Earth's sounds and images"],
        correctIndex: 3,
        explanation: "Each Voyager carries a gold-plated record with greetings in 55 languages, music, and sounds and pictures of life on Earth."
    ),
    QuizQuestion(
        question: "Which space telescope, launched in 2021, sees mainly in infrared light?",
        options: ["Hubble Space Telescope", "Kepler", "James Webb Space Telescope", "Chandra"],
        correctIndex: 2,
        explanation: "Webb's 6.5 m gold-coated mirror sees infrared light, letting it look through dust and back to some of the first galaxies."
    ),
    QuizQuestion(
        question: "In what year was the Hubble Space Telescope launched?",
        options: ["1975", "1990", "2001", "2010"],
        correctIndex: 1,
        explanation: "Hubble was carried up by the Space Shuttle in 1990 and, thanks to five servicing missions, is still working."
    ),
    QuizQuestion(
        question: "About how high above Earth does the International Space Station orbit?",
        options: ["About 400 km", "About 40 km", "About 4,000 km", "About 36,000 km"],
        correctIndex: 0,
        explanation: "The ISS flies about 400 km up, close enough to be seen with the naked eye as a bright moving dot."
    ),
    QuizQuestion(
        question: "How long does the International Space Station take to circle Earth once?",
        options: ["About 24 hours", "About 12 hours", "About 7 days", "About 90 minutes"],
        correctIndex: 3,
        explanation: "Travelling at about 28,000 km/h, the station laps Earth about 16 times a day, so its crew sees 16 sunrises daily."
    ),
    QuizQuestion(
        question: "Which rover landed in Mars's Jezero Crater in 2021?",
        options: ["Curiosity", "Opportunity", "Perseverance", "Sojourner"],
        correctIndex: 2,
        explanation: "Perseverance is collecting rock samples from an ancient river delta, searching for signs of past microbial life."
    ),
    QuizQuestion(
        question: "Which NASA lander touched down on Mars in 1976 and worked there for six years?",
        options: ["Mariner 4", "Viking 1", "Pathfinder", "Spirit"],
        correctIndex: 1,
        explanation: "Viking 1 landed in July 1976 and kept working for over six years, sending back the first clear pictures from the Martian surface."
    ),
    QuizQuestion(
        question: "Which spacecraft flew past all four giant planets?",
        options: ["Voyager 2", "Voyager 1", "Cassini", "Galileo"],
        correctIndex: 0,
        explanation: "Voyager 2 used a rare line-up of the planets to visit Jupiter, Saturn, Uranus and Neptune between 1979 and 1989."
    ),
    QuizQuestion(
        question: "How did the Cassini mission end in 2017?",
        options: ["It landed on Titan", "It flew out of the Solar System", "It crashed into Jupiter", "It dived into Saturn"],
        correctIndex: 3,
        explanation: "Low on fuel, Cassini was steered into Saturn so it could never contaminate moons like Enceladus that might hold life."
    ),
    QuizQuestion(
        question: "Which country landed Chandrayaan-3 near the Moon's south pole in 2023?",
        options: ["China", "Japan", "India", "Russia"],
        correctIndex: 2,
        explanation: "India became the first country to land near the lunar south pole, where water ice may hide in shadowed craters."
    ),
    QuizQuestion(
        question: "What is NASA's Artemis program working toward?",
        options: ["Landing on Venus", "Returning humans to the Moon", "Mining asteroids", "Visiting Jupiter's moons"],
        correctIndex: 1,
        explanation: "Artemis aims to land astronauts on the Moon for the first time since 1972, and to build toward staying there for longer."
    ),
    QuizQuestion(
        question: "What is the most fuel-efficient path between two planets' orbits called?",
        options: ["A Hohmann transfer orbit", "A gravity slingshot", "A geostationary orbit", "A polar orbit"],
        correctIndex: 0,
        explanation: "A Hohmann transfer is half an ellipse that touches both orbits: cheap on fuel, but slow. Try it in Mission Builder!"
    ),
    QuizQuestion(
        question: "Why do missions to Mars launch only about every 26 months?",
        options: ["Rockets take that long to build", "Mars's dust storms last two years", "Launch sites close in between", "Earth and Mars line up for an efficient trip only that often"],
        correctIndex: 3,
        explanation: "The planets must be in the right places for a transfer orbit, and Earth and Mars return to that line-up about every 26 months."
    ),
    QuizQuestion(
        question: "How long does a radio message take to travel from Mars to Earth?",
        options: ["Less than a second", "About 1 hour", "Between about 3 and 22 minutes", "About 2 days"],
        correctIndex: 2,
        explanation: "It depends where the planets are: about 3 minutes at their closest and over 20 at their farthest, so Mars rovers can't be driven live."
    ),
    QuizQuestion(
        question: "About how fast must a rocket go to escape Earth's gravity?",
        options: ["1.1 km/s", "11.2 km/s", "112 km/s", "300,000 km/s"],
        correctIndex: 1,
        explanation: "Escape velocity from Earth's surface is about 11.2 km/s, which is over 40,000 km/h."
    ),
    QuizQuestion(
        question: "Which rocket carried the Apollo astronauts to the Moon?",
        options: ["Saturn V", "Falcon 9", "The Space Shuttle", "Soyuz"],
        correctIndex: 0,
        explanation: "At 110 m tall, Saturn V is still one of the most powerful rockets ever flown."
    ),
    QuizQuestion(
        question: "What was the first spacecraft to land on a comet?",
        options: ["Rosetta", "Giotto", "Deep Impact", "Philae"],
        correctIndex: 3,
        explanation: "Rosetta's lander Philae touched down on comet 67P in November 2014, bouncing twice before coming to rest."
    ),
    QuizQuestion(
        question: "Which mission brought samples from asteroid Bennu back to Earth in 2023?",
        options: ["Hayabusa2", "Dawn", "OSIRIS-REx", "Lucy"],
        correctIndex: 2,
        explanation: "OSIRIS-REx grabbed rock and dust from Bennu in 2020 and dropped them to Earth in a capsule in September 2023."
    ),
    QuizQuestion(
        question: "What did NASA's DART mission do in 2022?",
        options: ["Landed on Mars", "Crashed into an asteroid to change its orbit", "Photographed a black hole", "Repaired a satellite"],
        correctIndex: 1,
        explanation: "DART hit the small asteroid Dimorphos and shortened its orbit by about 33 minutes, the first test of defending Earth from an asteroid."
    ),
    QuizQuestion(
        question: "Which NASA mission launched in 2024 to study Jupiter's moon Europa?",
        options: ["Europa Clipper", "Juno", "JUICE", "Galileo"],
        correctIndex: 0,
        explanation: "From 2030 Europa Clipper will fly past Europa dozens of times to find out whether its hidden ocean could support life."
    ),
    QuizQuestion(
        question: "What is a light-year?",
        options: ["The time light takes to reach Earth", "A year on a planet near another star", "How bright a star is", "The distance light travels in a year"],
        correctIndex: 3,
        explanation: "A light-year is a distance: about 9.46 trillion km, how far light travels in one year."
    ),
    QuizQuestion(
        question: "What is the nearest star to the Sun?",
        options: ["Sirius", "Polaris", "Proxima Centauri", "Betelgeuse"],
        correctIndex: 2,
        explanation: "Proxima Centauri, a small red dwarf, is about 4.2 light-years away."
    ),
    QuizQuestion(
        question: "What is the name of our galaxy?",
        options: ["Andromeda", "The Milky Way", "The Large Magellanic Cloud", "Triangulum"],
        correctIndex: 1,
        explanation: "The Milky Way is a barred spiral galaxy with hundreds of billions of stars; the Sun sits in one of its arms."
    ),
    QuizQuestion(
        question: "Which is the nearest large galaxy to the Milky Way?",
        options: ["Andromeda", "Sombrero", "Whirlpool", "Centaurus A"],
        correctIndex: 0,
        explanation: "Andromeda is about 2.5 million light-years away and heading for a collision with the Milky Way in about 4 to 5 billion years."
    ),
    QuizQuestion(
        question: "What colour are the hottest stars?",
        options: ["Red", "Yellow", "Orange", "Blue"],
        correctIndex: 3,
        explanation: "A star's colour shows its temperature: red stars are the coolest, while blue stars can be hotter than 30,000°C."
    ),
    QuizQuestion(
        question: "What will the Sun eventually become at the end of its life?",
        options: ["A black hole", "A neutron star", "A white dwarf", "A planet"],
        correctIndex: 2,
        explanation: "In about 5 billion years the Sun will swell into a red giant, then shed its outer layers and leave a small, hot white dwarf."
    ),
    QuizQuestion(
        question: "What is a supernova?",
        options: ["A newly born star", "The explosion of a star", "A very bright planet", "A cloud of dust"],
        correctIndex: 1,
        explanation: "A supernova can briefly outshine a whole galaxy, and it scatters elements like iron and gold into space."
    ),
    QuizQuestion(
        question: "What is a nebula?",
        options: ["A cloud of gas and dust in space", "A type of comet", "A small moon", "A group of galaxies"],
        correctIndex: 0,
        explanation: "Nebulae are where stars are born: gravity pulls their gas and dust together into new suns."
    ),
    QuizQuestion(
        question: "What is the brightest star in the night sky?",
        options: ["Polaris", "Vega", "Rigel", "Sirius"],
        correctIndex: 3,
        explanation: "Sirius is about 8.6 light-years away and about 25 times as luminous as the Sun."
    ),
    QuizQuestion(
        question: "How fast does light travel?",
        options: ["About 300 km per second", "About 3,000 km per hour", "About 300,000 km per second", "About 30 million km per second"],
        correctIndex: 2,
        explanation: "Light moves at about 299,792 km/s, fast enough to circle Earth more than seven times in one second."
    ),
    QuizQuestion(
        question: "About how old is the universe?",
        options: ["4.6 billion years", "13.8 billion years", "1 billion years", "100 billion years"],
        correctIndex: 1,
        explanation: "The universe began with the Big Bang about 13.8 billion years ago, about three times the age of the Solar System."
    ),
    QuizQuestion(
        question: "Which star stays almost still in the northern sky and has guided travellers for centuries?",
        options: ["Polaris, the North Star", "Sirius", "Betelgeuse", "Vega"],
        correctIndex: 0,
        explanation: "Polaris sits almost directly above Earth's north pole, so the whole night sky seems to turn around it."
    ),
    QuizQuestion(
        question: "What is at the centre of the Milky Way?",
        options: ["A giant star", "An empty void", "A huge planet", "A supermassive black hole"],
        correctIndex: 3,
        explanation: "Sagittarius A* is a black hole about 4 million times the Sun's mass; the first image of it was released in 2022."
    ),
    QuizQuestion(
        question: "In what year was Pluto reclassified as a dwarf planet?",
        options: ["1930", "1990", "2006", "2015"],
        correctIndex: 2,
        explanation: "In 2006 the International Astronomical Union decided Pluto hadn't cleared its orbit of other objects, so it became a dwarf planet."
    ),
    QuizQuestion(
        question: "What is the name of Pluto's largest moon?",
        options: ["Triton", "Charon", "Nix", "Phobos"],
        correctIndex: 1,
        explanation: "Charon is half as wide as Pluto, so big that the two orbit a point in the space between them."
    ),
    QuizQuestion(
        question: "Pluto has a huge heart-shaped plain. Who is it named after?",
        options: ["Clyde Tombaugh, who discovered Pluto", "The Roman god of love", "A NASA engineer's pet", "The first astronaut"],
        correctIndex: 0,
        explanation: "Tombaugh Regio honours Clyde Tombaugh, who discovered Pluto in 1930. Its left lobe is a vast plain of nitrogen ice."
    ),
    QuizQuestion(
        question: "Which dwarf planet is slightly more massive than Pluto?",
        options: ["Ceres", "Makemake", "Haumea", "Eris"],
        correctIndex: 3,
        explanation: "Eris, found in 2005, has about 27% more mass than Pluto. Its discovery led to Pluto's reclassification."
    ),
    QuizQuestion(
        question: "Where do most long-period comets come from?",
        options: ["The asteroid belt", "Saturn's rings", "The Oort Cloud", "The Sun's corona"],
        correctIndex: 2,
        explanation: "The Oort Cloud is a vast shell of icy bodies far beyond Pluto, perhaps reaching a quarter of the way to the nearest star."
    ),
    QuizQuestion(
        question: "Halley's Comet returns about every how many years?",
        options: ["7", "76", "300", "1,000"],
        correctIndex: 1,
        explanation: "Halley last passed in 1986 and will be back in 2061, so most people get one chance to see it."
    ),
    QuizQuestion(
        question: "What is a space rock that survives its fall and lands on Earth called?",
        options: ["A meteorite", "A meteor", "A comet", "A satellite"],
        correctIndex: 0,
        explanation: "It's a meteoroid in space, a meteor while it burns through the sky, and a meteorite once it lands."
    ),
    QuizQuestion(
        question: "What most likely wiped out the dinosaurs 66 million years ago?",
        options: ["A solar flare", "A comet's tail", "The Moon coming too close", "An asteroid impact"],
        correctIndex: 3,
        explanation: "An asteroid about 10 km wide struck what is now Mexico, leaving the Chicxulub crater and changing the climate worldwide."
    ),
    QuizQuestion(
        question: "How many planets are in our Solar System?",
        options: ["Seven", "Nine", "Eight", "Ten"],
        correctIndex: 2,
        explanation: "Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus and Neptune. Pluto was counted as the ninth until 2006."
    ),
    QuizQuestion(
        question: "Which two planets have no moons?",
        options: ["Mars and Venus", "Mercury and Venus", "Mercury and Mars", "Uranus and Neptune"],
        correctIndex: 1,
        explanation: "Mercury and Venus are the only planets without moons; Mars has two tiny ones."
    ),
    QuizQuestion(
        question: "How much would you weigh on the Moon compared with Earth?",
        options: ["About one sixth", "About half", "About the same", "About twice as much"],
        correctIndex: 0,
        explanation: "The Moon's gravity is about 16.5% of Earth's, so a 60 kg person would weigh like 10 kg there. Try the Weight Calculator!"
    ),
    QuizQuestion(
        question: "Gravity on Mars is about what fraction of Earth's?",
        options: ["About 10%", "About 90%", "About twice Earth's", "About 38%"],
        correctIndex: 3,
        explanation: "Mars is smaller and less massive, so its surface gravity is about 38% of Earth's. You could jump nearly three times as high."
    ),
    QuizQuestion(
        question: "By the most common definition, where does space begin?",
        options: ["About 10 km up", "About 1,000 km up", "About 100 km up (the Kármán line)", "At the Moon"],
        correctIndex: 2,
        explanation: "The Kármán line, about 100 km above sea level, is the widely used boundary between Earth's atmosphere and outer space."
    ),
    QuizQuestion(
        question: "What is the stream of charged particles flowing out from the Sun called?",
        options: ["Sunlight", "The solar wind", "The ozone layer", "Cosmic dust"],
        correctIndex: 1,
        explanation: "The solar wind blows out at around 400 km/s in every direction, shaping comet tails and causing auroras when it reaches Earth."
    ),
    QuizQuestion(
        question: "About how hot is the visible surface of the Sun?",
        options: ["About 5,500°C", "About 500°C", "About 55,000°C", "About 15 million °C"],
        correctIndex: 0,
        explanation: "The photosphere glows at about 5,500°C: far cooler than the 15 million °C core, and oddly cooler than the corona above it."
    ),
    QuizQuestion(
        question: "Among the planets, which has the largest moon compared with its own size?",
        options: ["Jupiter", "Saturn", "Mars", "Earth"],
        correctIndex: 3,
        explanation: "Our Moon is over a quarter of Earth's width. Jupiter's Ganymede is bigger, but tiny next to Jupiter."
    ),
    QuizQuestion(
        question: "Dust storms on Mars can sometimes do what?",
        options: ["Reach the Moon", "Put out its volcanoes", "Cover the entire planet", "Turn the sky green"],
        correctIndex: 2,
        explanation: "Every few years a dust storm grows to wrap the whole planet for weeks. One ended the Opportunity rover's mission in 2018."
    ),
    QuizQuestion(
        question: "Jupiter's moon Ganymede is bigger than which planet?",
        options: ["Mars", "Mercury", "Earth", "Venus"],
        correctIndex: 1,
        explanation: "Ganymede is about 5,268 km across, wider than Mercury, though Mercury has about twice its mass."
    ),
    QuizQuestion(
        question: "What is Titan's thick atmosphere mostly made of?",
        options: ["Nitrogen", "Oxygen", "Carbon dioxide", "Helium"],
        correctIndex: 0,
        explanation: "Titan's air is about 95% nitrogen, with a surface pressure about 1.5 times Earth's. It's the only moon with a thick atmosphere."
    )
]
