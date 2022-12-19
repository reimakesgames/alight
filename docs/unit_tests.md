# Unit Tests
Unit tests are made with [TestEZ](https://roblox.github.io/testez/) and tested with [run-in-roblox](https://github.com/rojo-rbx/run-in-roblox)

Currently, the unit tests are not automated by the CI/CD system.
But you can run them locally and post your results in your pull request.

!!! Note
	Unit tests are not required for your pull request to be accepted.
	But it is recommended.

---

## Creating a Unit Test
To create a unit test, you need to create a file in the `test` folder.
The file name should be the same as the module name, but with `.spec` at the end.
For example, if you have a module called `MyModule`, you would create a file called `MyModule.spec.lua`.

```title="Explorer View"
src
└───shared
	└───Classes
		└───YourClass.lua
test
├───YourClass.spec.lua
└───HEAD.lua

```

```title="Roblox Explorer View"
ServerStorage
└───Tests
	├───YourClass.spec.lua
	└───HEAD.lua
ReplicatedStorage
└───Classes
	└───YourClass.lua
```

!!! note
	You only have to create a Unit Test file inside the `test` folder.

	You don't need to fiddle around with the other directories. This is just for reference.

---

## Writing a Unit Test
This is not going to go into detail on how to write a unit test, as that is out of the scope of this documentation.

The common things you would want to test are:

* arguments and returns of your functions or methods
* handling of wrong arguments and errors
* handling of potential edge cases

Example:

```lua title="MyModule.lua" linenums="1"
local MyModule = {}

function MyModule:foo()
	return "bar"
end

function MyModule:shouldIError(bool: boolean)
	if bool then
		error("I should error")
	end
end

return MyModule
```

```lua title="MyModule.spec.lua" linenums="1"
local MyModule = require(path.to.MyModule)

return function()
	describe("MyModule", function()
		it("should return bar", function()
			expect(MyModule:foo()).to.equal("bar")
		end)

		it("should error", function()
			expect(function()
				MyModule:shouldIError(true)
			end).to.throw()
		end)

		it("should not error", function()
			expect(function()
				MyModule:shouldIError(false)
			end).never.to.throw()
		end)
	end)
end
```

```lua title="HEAD.lua" linenums="1" hl_lines="6"
local ServerStorage = game:GetService("ServerStorage")
local Tests = ServerStorage:WaitForChild("Tests")
local Bootstrapper = require(Tests.container.bootstrap)

Bootstrapper:run({
	Tests["MyModule.spec"];
})
```

---

## Adding a Unit Test
To add a unit test in the tester, you need to add the test file to the `Bootstrapper:run` function in the `tests/HEAD.lua` file.
In the `tests/HEAD.lua` file, you will see the following code:

```lua
local ServerStorage = game:GetService("ServerStorage")
local Tests = ServerStorage:WaitForChild("Tests")
local Bootstrapper = require(Tests.container.bootstrap)

Bootstrapper:run({
	-- Tests is essentially the test folder in this case
	-- So running the test file would be Tests.MyModule.spec
	Tests["MyModule.spec"];

	-- You can also run multiple test files
	Tests["MyModule.spec"];
	Tests["MyOtherModule.spec"];
})
```

!!! note
	You just have to add the test files you want to run to the `Bootstrapper:run` function.

	The `Bootstrapper:run` function will run all the tests in the order you put them in.

!!! warning
	i consider you a funny person if you test the tester file that contains itself in its tests and causes an infinite loop

	don't test the test file that contains itself in its tests because if it does that, it tests itself which requires itself to test the tests inside BUT it contains itself in that test so the test that was tested tests a new test

	please don't.
	i beg you.

---

## Running a Unit Test
To run a unit test, you need to run the `unit.sh` script.
This script will run the `HEAD.lua` file in the root directory of the project.
It will print the results of the unit tests to your Visual Studio Code console. (Colored too! yayyyy)
You then can use your snipping tool to take a screenshot or copy the output and paste it in your pull request.

An example of the output is:

```bash
# This will be colored but markdown doesn't support that

$ ./unit.sh
Building project 'hybrid-conflict'
Built project to out.rbxl
Running
[ Tests ]:
Test results:
[+] test
   [+] this thing
      [+] does nothing
1 passed, 0 failed, 0 skipped
[ Completed ]
$
```

!!! Warning
	Keep that in mind that you need to run the tests whenever you make changes to the code.
