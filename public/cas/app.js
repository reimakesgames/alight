let prompts = {
	"what": `CAS is a console-based article system, it is used as a place to list information. It is not case sensitive<br>
	Written by Agent 01`,
	"fira": "Fira is a combat company formed by █████████████ during ███-██-████, and is currently active in ██████████████████, combatting the mirror group",
	"mirror group": "The mirror group is the Fira group, but in the mirror universe, they are called the Fira Legion",
	"mirror universe": "The mirror universe was created by ████████ (██), it was started during DSF 0, and is continuing to split farther and farther away from the original universe",
	"dsf": "DSF is a time reference, it stands for 'Days Since Flashpoint', and is used to reference the time since the mirror universe was created",
	"flashpoint": "Flashpoint is the event that created the mirror universe, it was caused by ████████████████████████████████████ during an experiment by Agent (01)",
	"agent": "Agent is a term used to refer agents of the Fira Company",
	"01": "Hello, I am Agent 01, My name is █████, and I am a mage of the Fira Company",
}

let usefulText = `
Here's information for how to kill yourself

1. Don't say goodbye to friends and family<br>
Convince yourself that they'll forget<br>
2. Don't write a note telling them why you're gone<br>
'Cause that'll just make you upset<br>

3. Give all your money to some charity<br>
Pretend like you're worth less than that<br>
4. And after you've thrown all of your possessions<br>
It's time to come up with a plan<br>

I've tried so many times<br>
But I can't do anything right<br>
Maybe there is an easier way<br>
I'll go search up a guide online<br>

Fail: I have to make sure I go through with this<br>
Because the last time, I was fined<br>
Cry: Since I can't find anything that's worth trying<br>
I guess I'll live another while<br>

5. It's time again to try out therapy<br>
Even if last time didn't help<br>
6. Although the insurance that I pay yearly<br>
It doesn't cover mental health<br>

I've tried so many times<br>
But I can't do anything right<br>
Maybe there is an easier way<br>
I'll go search up a guide online<br>

Live: Maybe I'm way too good at living<br>
'Cause after all, I'm still alive<br>
Result: The only search result that ends up showing<br>
"Top Ten Things To Do Before You Die" (Top ten things to do before you die)<br>
I'll give this list a few more tries (Please give this list a few more tries)<br>
I guess I'll live another while`

const console = document.getElementById("console");

function enterCommand() {
	let div = document.createElement("div");
	div.className = "entry";

	let prompt = document.createElement("span");
	prompt.className = "prompt";
	prompt.textContent = "fira-admin@cas> ";

	let active = document.createElement("span");
	active.className = "command";
	active.id = "active";
	active.innerHTML = "";
	active.spellcheck = false;

	div.appendChild(prompt);
	div.appendChild(active);
	console.appendChild(div);
	setTimeout(function() {
		active.contentEditable = true;
		active.focus();
	}, 0);
}

addEventListener("keydown", function(event) {
	if (event.key == "Enter") {
		let active = document.getElementById("active");
		// active.textContent = active.textContent.replace(/(\r\n|\n|\r)/gm, "");

		let command = active.textContent;
		active.id = "";
		active.contentEditable = false;

		if (command.toLowerCase() in prompts) {
			let entry = document.createElement("div");
			entry.className = "entry";
			entry.innerHTML = prompts[command.toLowerCase()] + "<br><br>";
			console.appendChild(entry);
		} else {
			let entry = document.createElement("div");
			entry.className = "entry";
			entry.innerHTML = "Unknown command: " + command + "<br><br>";
			console.appendChild(entry);
		}
		if (command == "rick") {
			window.open("https://www.youtube.com/watch?v=dQw4w9WgXcQ");
		} else if (command == "clear") {
			console.innerHTML = "";
		} else if (command == "kys") {
			let entry = document.createElement("div");
			entry.className = "entry";
			entry.innerHTML = usefulText;
			console.appendChild(entry);
		} else if (command == "launch") {
			window.open("roblox://placeId=2597632885")
		} else if (command == "help") {
			let entry = document.createElement("div");
			entry.className = "entry";
			entry.innerHTML = "Commands: <br> clear, kys, launch, help";
			console.appendChild(entry);
		}
		enterCommand();
	}
});
addEventListener("click", function() {
	let active = document.getElementById("active");
	if (active) {
		active.focus();
	}
});

enterCommand();
