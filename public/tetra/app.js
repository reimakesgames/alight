const title = document.getElementById('title');
const button = document.getElementById('button');
const epilepsyWarning = document.getElementById('epilepsy-warning');

const root = document.getElementById('root');
const lyrics = document.getElementById('lyrics');

const introMusic = document.getElementById('intro-music');
const music = document.getElementById('music');

var chorus
fetch('./lyrics.json')
	.then(response => response.json())
	.then(data => {
		chorus = data.chorus;
	});
const songBpm = 116;
const TetraPurple = "#f765d5";

epilepsyWarning.style.color = 'red';
epilepsyWarning.style.translate = 'translate(0, 0)';
epilepsyWarning.style.textShadow = '0 0 64px #f008';
epilepsyWarning.style.opacity = 1;

title.style.color = 'white';
title.style.textShadow = '0 0 64px #fff8';
title.style.opacity = 1;

button.style.opacity = 1;











function createCenterPopEffect(scaleOverride, timeOverride) {
	var pop = document.createElement("div");
	pop.className = "pop";
	pop.id = "pop";
	// pop.style.animation = "pop 0.3s";
	pop.style.animation = "pop " + (timeOverride || "0.3") + "s";
	pop.style.scale = scaleOverride || "3";
	pop.style.borderColor = TetraPurple;
	document.getElementById("root").appendChild(pop);

	setTimeout(function () {
		pop.remove();
	}, (timeOverride * 1000) || 350);
}



function startLoop() {
	music.currentTime = 0;
	music.play();

	const yonButInKeychainAgainWtf = document.createElement("div");
	yonButInKeychainAgainWtf.className = "yonTemp";
	yonButInKeychainAgainWtf.id = "yonTemp";
	document.getElementById("root").appendChild(yonButInKeychainAgainWtf);

	document.getElementById("subtitle").remove();

	root.classList.add("disable-css-transitions");
	root.style.rotate = "80deg";
	root.style.scale = "2";
	root.classList.remove("disable-css-transitions");

	setTimeout(() => {
		// root.style.transition = "0.7s cubic-bezier(.6,0,.85,.3)",
		// reverse the transition so it looks like it's going back to normal
		// cubic-bezier(.6,0,.85,.3) is the same as cubic-bezier(.15,.7,.4,1)
		root.style.transition = "0.7s cubic-bezier(.15,.7,.4,1)",
		root.style.rotate = "0deg";
		root.style.scale = "1";
	}, 10);
	const loopLength = 60000 / songBpm * 72
	for (let i = 0; i < 72 * 4; i++) {
		setTimeout(() => {
			lyrics.innerText = chorus[i];
			if (i % 4 == 0) {
				root.style.animation = "beat 0.3s";
			} else if (i % 4 == 1) {
				root.style.animation = "";
			}

			if (i == 42 || i == 44) {
				createCenterPopEffect(3, 0.3);
			}
		}, (60000 / songBpm) * (i + 1) / 4);
	}

	setTimeout(() => {
		startLoop();
	}, 37200);
}

function startIntro() {
	introMusic.play();
	setTimeout(() => {
		startLoop();
	}, 60000 / songBpm * 7.95);
	for (let i = 0; i < 32; i++) {
		setTimeout(() => {
			if (i == 16) {
				let subtitle = document.createElement("div");
				subtitle.className = "subtitles";
				subtitle.id = "subtitle";
				subtitle.textContent = "back then, I...";
				document.getElementById("root").appendChild(subtitle);
			}

			if (i == 24) {
				createCenterPopEffect(2, 0.3);
			} else if (i == 25) {
				createCenterPopEffect(1.5, 0.3);
			} else if (i == 27) {
				createCenterPopEffect(1, 0.3);
				root.style.transition = "0.7s cubic-bezier(.6,0,.85,.3)",
				root.style.rotate = "-80deg";
				root.style.scale = "3";
			} else if (i == 29) {
				createCenterPopEffect(0.5, 0.3);
			}
		}, (60000 / songBpm) * (i + 1) / 4);
	}
}

button.addEventListener('click', () => {
	epilepsyWarning.style.opacity = 0;
	title.style.opacity = 0;
	button.style.opacity = 0;

	setTimeout(() => {
		epilepsyWarning.style.display = 'none';
		title.style.display = 'none';
		button.style.display = 'none';

		startIntro();
	}, 2000);
});
