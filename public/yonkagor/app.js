// change window title to lyrics in a cycle

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

function createCenterPopEffect() {
	var pop = document.createElement("div");
	pop.className = "pop";
	pop.id = "pop";
	pop.style.animation = "pop 0.3s";
	pop.style.scale = "3";
	pop.style.borderColor = TetraPurple;
	document.body.appendChild(pop);

	// wait for the animation to finish
	setTimeout(function() {
		pop.remove();
	}, 350);
}

var clap = document.getElementById("clap");
clap.play();

setInterval(function() {
	document.getElementById("lyrics").textContent = lyrics[i];
	i++;
	if (i >= lyrics.length) {
		i = 0;
		clap.load()
		clap.play();
	}
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
}, interval);
