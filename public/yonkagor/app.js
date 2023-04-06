// change window title to lyrics in a cycle

var introLyrics = [
	"",
	"",
	"",
	"",
	"",
	"",
	"Back",
	"Back",
	"Back then",
	"Back then",
	"Back then",
	"Back then",
	"Back then I",
	"Back then I",
	"Back then I",
	"Back then I",
]

var lyrics = [
	// "Back",
	// "Back then",
	// "Back then",
	// "Back then",
	// "Back then",
	// "Back then I",
	// "Back then I",
	// "Back then I",
	// "Back then I",
	"Li",
	"Li",
	"Li",
	"Li",
	"Listened",
	"Listened",
	"Listened",
	"Listened",
	"Listened to",
	"Listened to",
	"Listened to",
	"Listened to your",
	"Listened to your",
	"Listened to your",
	"Listened to your voice",
	"Listened to your voice",
	"",
	"",
	"Twen",
	"Twen",
	"Twenty",
	"Twenty",
	"Twenty Four",
	"Twenty Four",
	"Twenty Four Se",
	"Twenty Four Se",
	"Twenty Four Seven",
	"Twenty Four Seven",
	"We",
	"We",
	"We we're",
	"We we're",
	"We we're dan",
	"We we're dan",
	"We we're dancing",
	"We we're dancing",
	"We we're dancing through",
	"We we're dancing through",
	"We we're dancing through it",
	"We we're dancing through it",
	"We we're dancing through it all",
	"We we're dancing through it all",
	">CLAP<",
	"",
	"<CLAP>",
	"",
	// "Dancing through it",
	"Dan",
	"Dan",
	"Dan",
	"Dan",
	"Dancing",
	"Dancing",
	"Dancing through",
	"Dancing through",
	"Dancing through it",
	"Dancing through it",
	"Al",
	"Al",
	"Al",
	"Al",
	"Although",
	"Although",
	"Although",
	"Although",
	// "I do miss the times we've spent together",
	"I",
	"I",
	"I",
	"I",
	"I do",
	"I do",
	"I do",
	"I do",
	"I do miss",
	"I do miss",
	"I do miss",
	"I do miss the",
	"I do miss the",
	"I do miss the",
	"I do miss the times",
	"I do miss the times",
	"I do miss the times",
	"I do miss the times",
	"We've",
	"We've",
	"We've spent",
	"We've spent",
	"We've spent to",
	"We've spent to",
	"We've spent toget",
	"We've spent toget",
	"We've spent together",
	"We've spent together",
	"We've spent together",
	"We've spent together",
	"We've spent together",
	"We've spent together",
	"",
	"",
	"You're",
	"You're",
	"You're",
	"You're so",
	"You're so",
	"You're so",
	"You're so twen",
	"You're so twen",
	"You're so twen",
	"You're so twenty",
	"You're so twenty",
	"You're so twenty",
	"You're so twenty twen",
	"You're so twenty twen",
	"You're so twenty twen",
	"You're so twenty twen",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
	"You're so twenty twenty",
];

const BPM = 116; // beats per minute
const BeatSubdivision = 4; // 4 = quarter note, 8 = eighth note, 16 = sixteenth note

const TetraPurple = "#f765d5";

var i = 0;
var interval = 60000 / BPM / BeatSubdivision;

// load the song first
// has an id of clap in the dom

function createRandomPopEffect() {
	var pop = document.createElement("div");
	pop.className = "pop";
	pop.id = "pop";
	pop.style.animation = "pop 0.3s";
	pop.style.transform = "translate(" + (Math.random() * 100 - 50) + "vw, " + (Math.random() * 100 - 50) + "vh)";
	document.body.appendChild(pop);

	// wait for the animation to finish
	setTimeout(function() {
		pop.remove();
	}, 350);
}

function createCenterPopEffect(scaleOverride, timeOverride) {
	var pop = document.createElement("div");
	pop.className = "pop";
	pop.id = "pop";
	// pop.style.animation = "pop 0.3s";
	pop.style.animation = "pop " + (timeOverride || "0.3") + "s";
	pop.style.scale = scaleOverride || "3";
	pop.style.borderColor = TetraPurple;
	document.body.appendChild(pop);

	// wait for the animation to finish
	setTimeout(function() {
		pop.remove();
	}, 350);
}

function placeEverything() {
	// create this
	// 	<audio id="clap" src="./yjlpmjingle.mp3" preload="auto"></audio>
	// 	<div class="imagemax" id="TETRAAAAA">
	// </div>
	// <div class="lyrics" id="lyrics"></div>

	var music = document.createElement("audio");
	music.id = "clap";
	music.src = "./yjlpmjingle.mp3";
	music.preload = "auto";
	document.body.appendChild(music);

	var intro = document.createElement("audio");
	intro.id = "intro";
	intro.src = "./yjlpmjingle_intro.mp3";
	intro.preload = "auto";
	document.body.appendChild(intro);

	var lyrics = document.createElement("div");
	lyrics.className = "lyrics";
	lyrics.id = "lyrics";
	document.body.appendChild(lyrics);
}

function start() {
	placeEverything();

	var intro = document.getElementById("intro");
	var music = document.getElementById("clap");

	var introi = 0;

	// setInterval(function() {
	// 	if (introi == 0) {
	// 		intro.load();
	// 		intro.play();
	// 	}
	// 	// at steps 11 to 15, create a pop effect
	// 	if (introi == 11 || introi == 12 || introi == 13 || introi == 14 || introi == 15) {
	// 		createCenterPopEffect();
	// 	}
	// 	introi++;
	// }, interval);

	// replace with for loop

	document.getElementById("thetext").remove();
	document.title = "uh oh";
	for (let i = 1; i < 16; i++) {
		setTimeout(function() {
			if (i == 1) {
				intro.load();
				intro.play();
			}
			// at steps 11 to 15, create a pop effect
			if (i == 11 || i == 12) {
				createCenterPopEffect("3", "0.2");
			} else if (i == 13 || i == 14 || i == 15) {
				createCenterPopEffect("2", "0.2");
			}
			document.getElementById("lyrics").textContent = introLyrics[i];
		}, interval * i);
	}

	setTimeout(function() {
		document.title = "yon dancing no way"

		var tetra = document.createElement("div");
		tetra.className = "imagemax";
		tetra.id = "TETRAAAAA";
		document.body.appendChild(tetra);

		setInterval(function() {
			if (i == 0) {
				music.load();
				music.play();
			}
			document.getElementById("lyrics").textContent = lyrics[i];
			i++;
			// Cowbell
			if (i == 59 || i == 60 || i == 62 || i == 63 || i == 64) {
				createRandomPopEffect();
			}
			// Yon clapping (clap clap)
			if (i == 43 || i == 45) {
				createCenterPopEffect();
			}

			if (i == 49 || i == 53 || i == 57 || i == 61) {
				document.getElementById("lyrics").style.animation = "beat 0.2s";
			} else if (i == 50 || i == 54 || i == 58 || i == 62) {
				document.getElementById("lyrics").style.animation = "";
			}

			if (i == 97 || i == 101 || i == 105 || i == 109) {
				document.getElementById("lyrics").style.animation = "beat 0.2s";
			} else if (i == 113 || i == 117 || i == 121 || i == 125) {
				document.getElementById("lyrics").style.animation = "beat 0.2s";
				document.getElementById("TETRAAAAA").style.animation = "beat2 0.2s";
			} else if (i == 98 || i == 102 || i == 106 || i == 110 || i == 114 || i == 118 || i == 122 || i == 126 || i == 130 || i == 134 || i == 138 || i == 142) {
				document.getElementById("lyrics").style.animation = "";
				document.getElementById("TETRAAAAA").style.animation = "";
			}
			if (i >= lyrics.length) {
				i = 0;
			}
		}, interval);
	}, interval * 16);
}

var debounce = true;
addEventListener("focus", function() {
	if (debounce) {
		debounce = false;
		start();
	}
});
