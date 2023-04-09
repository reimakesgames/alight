const title = document.getElementById('title');
const button = document.getElementById('button');
const epilepsyWarning = document.getElementById('epilepsy-warning');

const root = document.getElementById('root');
const lyrics = document.getElementById('lyrics');

const introMusic = document.getElementById('intro-music');
const music = document.getElementById('music');

let chorus
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

const imageContainer = document.getElementById('yonSF1');
const image = new Image();
image.src = './tetra_transparent.png';

function ColorImage(image, targetContainer, r, g, b) {
	const canvas = document.createElement('canvas');
	canvas.width = image.width;
	canvas.height = image.height;

	const context = canvas.getContext('2d');
	context.drawImage(image, 0, 0);

	const imageData = context.getImageData(0, 0, canvas.width, canvas.height);

	for (let i = 0; i < imageData.data.length; i += 4) {
		imageData.data[i] = r; // Set red channel to 255 (white)
		imageData.data[i + 1] = g; // Set green channel to 255 (white)
		imageData.data[i + 2] = b; // Set blue channel to 255 (white)
	}

	context.putImageData(imageData, 0, 0);

	const whiteUrl = canvas.toDataURL('image/png');

	targetContainer.style.backgroundImage = `url(${whiteUrl})`;
};

const whiteTetra = document.createElement("div");
whiteTetra.className = "yonSolidFrame1";
whiteTetra.style.transform = "translate(10%, -15%)";

const tetra = document.createElement("div");
tetra.className = "yonFrame1";
tetra.style.transform = "translate(-20%, -15%) rotate(-10deg)";

const tetraDancing = document.createElement("div");
tetraDancing.className = "yonFrame2";

const tetraClapping = document.createElement("div");
tetraClapping.className = "yonFrame3";

const pinkTetra = document.createElement("div");
pinkTetra.className = "yonFrame1";
pinkTetra.style.zIndex = 4;
pinkTetra.style.transform = "translate(-19%, -16%) rotate(-10deg)";
const yellowTetra = document.createElement("div");
yellowTetra.className = "yonFrame1";
yellowTetra.style.zIndex = 4;
yellowTetra.style.transform = "translate(-21%, -14%) rotate(-10deg)";

image.onload = function () {
	ColorImage(image, whiteTetra, 255, 255, 255);
	ColorImage(image, yellowTetra, 249, 194, 43);
	ColorImage(image, pinkTetra, 255, 100, 191);
}










function createCenterPopEffect(scaleOverride, timeOverride) {
	let pop = document.createElement("div");
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

function createFadeOutEffect(color) {
	let fadeOut = document.createElement("div");
	fadeOut.className = "fadeOut";
	fadeOut.style.backgroundColor = color;
	setTimeout(function () {
		fadeOut.style.opacity = 0;
	}, 10);
	setTimeout(function () {
		fadeOut.remove();
	}, 500);
	document.getElementById("transition-root").appendChild(fadeOut);
}



function startLoop() {
	createFadeOutEffect("#FFFFFF");
	root.appendChild(whiteTetra);
	document.getElementById("subtitle").remove();
	setTimeout(function () {
		createFadeOutEffect("#FFFFFF");
	}, 60000 / songBpm);


	music.currentTime = 0;
	music.play();

	const yonButInKeychainAgainWtf = document.createElement("div");
	yonButInKeychainAgainWtf.className = "yonTemp";
	yonButInKeychainAgainWtf.id = "yonTemp";
	root.appendChild(yonButInKeychainAgainWtf);

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

	const weWere = document.createElement("div");
	weWere.className = "weWere";
	weWere.innerText = "WE WERE";

	for (let i = 0; i < 72 * 4; i++) {
		setTimeout(() => {
			lyrics.innerText = chorus[i];
			// if (i % 4 == 0) {
			// 	root.style.animation = "beat 0.3s";
			// } else if (i % 4 == 1) {
			// 	root.style.animation = "";
			// }
			if (i == 4) {
				whiteTetra.remove();
				root.appendChild(tetra);
				root.appendChild(pinkTetra);
				root.appendChild(yellowTetra);
				setTimeout(() => {
					tetra.style.transform = "translate(-15%, -15%) rotate(5deg) scale(1.05)";
					pinkTetra.style.transform = "translate(-14%, -16%) rotate(5deg) scale(1.05)";
					yellowTetra.style.transform = "translate(-16%, -14%) rotate(5deg) scale(1.05)";
				}, 10);
			} else if (i == 28) {
				tetra.remove();
				pinkTetra.remove();
				yellowTetra.remove();
				root.appendChild(tetraDancing);
				root.appendChild(weWere);
				tetraDancing.style.filter = "brightness(0.4)";
			} else if (i == 32) {
				weWere.remove();
				tetraDancing.style.filter = "brightness(1)";
			}

			if (i == 8 || i == 12 || i == 16 || i == 20 || i == 24 || i == 32 || i == 36 || i == 40 || i == 48 || i == 52 || i == 56 || i == 60) {
				root.style.animation = "beat 0.3s";
				setTimeout(() => {
					root.style.animation = "";
				}, 300);
			}

			if (i == 42) {
				createCenterPopEffect(3, 0.3);
				root.appendChild(tetraClapping);
			} else if (i == 44) {
				createCenterPopEffect(2, 0.3);
			} else if (i == 46) {
				tetraClapping.remove();
			} else if (i == 64) {
				tetraDancing.remove();
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
