/**
 * Task 1: Repeating Numbers
 * 
 * Repeats a set of given numbers a specified number of times. The repeated numbers in the set are separated by commas
 *
 * @function repeatNumbers
 * @param {Array.<Array.<number>>} data - Set of numbers to repeat
 * @returns {string}
 */
var repeatNumbers = function(data)
{	
	/**
	 * @type {string}
	 */
	var result = ""; //This will contain the sequence of repeated numbers

	//Go through each set of numbers from the array
	for (var n=0; n<data.length; n++)
	{
		//Only add a comma if we have more than one repeated number in the set
		if (n != 0)
		{
			result += ", ";
		}
		
		var num = data[n][0];		//get the number to repeat
		var repeated = data[n][1];	//get the number of times to repeat that number

		//Repeat the number
		for (var p=0; p<repeated; p++)
		{
			result += num + ""; //append the repeated number to final output
		}
	}

	return result;
};

/**
 * Task 2: Conditional Sum
 * 
 * Sum a all the even numbers in a set if asked for evens, and sum all the odd numbers in a set when asked for odds
 * 
 * @function conditionalSum
 * @param {Array.<number>} values - Set of numbers to sum
 * @param {string} condition - specified whether to add even or odd numbers
 * @returns {string} Returns the repeated numbers with each separated by commas
 */
var conditionalSum = function(values, condition)
{
	/**
	 * @type {number}
	 */
	var sum = 0; //init final sum with 0 in case params contain errors

	//Search numbers in array for odds/evens
	for (var i=0; i<values.length; i++)
	{
		//Only integers can be even or odd, so skip any non-integers (and non-numbers)
		if (Number.isInteger(values[i]) == false) //number is not an integer...
		{
			continue;							  //skip to next number
		}

		//Only sum odd/even integers depending on specified condition
		if (condition === "even")
		{
			if (values[i] % 2 == 0) 	//any number divisible by 2 is even
			{
				sum += values[i];		//sum even numbers
			}
		}
		else if (condition === "odd")	//any number not divisible by 2 is odd
		{
			if (values[i] % 2 != 0)
			{
				sum += values[i];		//sum odd numbers
			}
		}
	}

	return sum;
};

/**
 * Task 3: Talking Calendar
 * 
 * Take a string formatted as "YYYY/MM/DD" and express that human-readable date in words
 * 
 * @function talkingCalendar
 * @param {string} date - represents date in "YYYY/MM/DD" format. We'll assume the date is valid (e.g. not "2018/02/31") 
 * @returns {string} the inputted date expressed in words
 */
var talkingCalendar = function(date)
{
	/**
	 * @type {string}
	 */
	var finalDate = ""; //represents the date spelled out in words

	/**
	 * @type {number}
	 */
	var tmpMonth = parseInt(date.substr(5, 2)) - 1; //convert month part to a number and offset for array
	
	/**
	 * @type {string}
	 */
	var month;				//get the month spelled out in words

	/**
	 * @const {Array.<string>}
	 */
	var months = 			//easy way to convert numeric month to words
	[
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December"
	];
	
	//Ensure value for months is valid
	if (tmpMonth >= 0 && tmpMonth <= 12)
	{
		month = months[tmpMonth]; //get the word equivalent of the month
	}

	//Add the named month to the final date
	finalDate += month;

	//Get the day of the month
	/**
	 * @type {string}
	 */
	var day = date.substr(8);			//get 2-digit day of month
	finalDate += " " + parseInt(day); 
	
	//Determine the ordinal text to use based on the last digit
	/**
	 * @type {string}
	 */
	var ordinal = day.substr(1); //get the last digit from the day
	
	//Get ordinal text based on last digit and append to final date
	switch (ordinal)
	{
		case "1": finalDate += "st"; break;
		case "2": finalDate += "nd"; break;
		case "3": finalDate += "rd"; break;
		default: finalDate += "th";
	}

	//Append the year portion to final date
	/**
	 * @type {string}
	 */
	var year = date.substr(0, 4);
	finalDate += " " + year;

	return finalDate;
};

/**
 * Task 4: Challenge Calculator
 * 
 * Return the denominations to use when issuing change for a purchase
 * 
 * @function calculateChange
 * @param {number} total - the amount due for purchase
 * @param {number} cash - the amount paid by the customer
 * @returns {Object.<string, number>} denominations of the change or empty object if no change to give
 */
var calculateChange = function(total, cash)
{
	//Calculate change to distribute
	/**
	 * @type {number}
	 */
	var changeRemaining = cash - total;

	//Don't bother checking for change if customer gives exact change or underpays
	if (changeRemaining <= 0)
	{
		return {};
	}

	//Define the various denominations
	/**
	 * @const {Object.<string, number>}
	 */
	var denomTypes =
	[
		{ name: "twentyDollar", value: 2000},	//$20
		{ name: "tenDollar", value: 1000},		//$10
		{ name: "fiveDollar", value: 500},		//$5
		{ name: "twoDollar", value: 100},		//$2
		{ name: "oneDollar", value: 100},		//$1
		{ name: "quarter", value: 25},			//$0.25
		{ name: "dime", value: 10},				//$0.10
		{ name: "nickel", value: 5},			//$0.05
		{ name: "penny", value: 1},				//$0.01
	];

	/**
	 * @type {Object.<string, number>}
	 */
	var finalChange = {}; //holds all the denominations to be given as change

	//Get the denominations to give back by iterating through them in descending order. the total number of a particular denomination is the quotient when remaining change is divided by the value of 1 unit of the denomination
	for (var c=0; c<denomTypes.length; c++)
	{
		/**
		 * @type {number}
		 */
		var denom = Math.floor(changeRemaining / denomTypes[c].value); //get total number of denominations
		
		/**
		 * @type {number}
		 */
		var changeRemaining = changeRemaining % denomTypes[c].value; //get the change left after taking out the current denomination amount

		//Add denomination to final array
		if (denom > 0)	//ensure we have some of this denomination to add
		{
			finalChange[denomTypes[c].name] = denom;
		}
	}

	return finalChange;
}

//Test the various functons
var numsToRepeat = [[1, 10], [56, 7]];
console.log("Task 1\n======");
console.log("Input: data=[[1, 10], [56, 7]]");
console.log("Output: " + repeatNumbers(numsToRepeat));
console.log("\n");
numsToRepeat = [[85, 2]];
console.log("Input: data=[[85, 2]]");
console.log("Output: " + repeatNumbers(numsToRepeat));
console.log("\n");

var conditionalNums = [1, 2, 3, 4, 5];
console.log("Task 2\n======");
console.log("Input: values=[" + conditionalNums + "] | condition=\"odd\"");
console.log("Output: " + conditionalSum(conditionalNums, "odd"));
console.log("\n");

console.log("Task 3\n======");
console.log("Input: date=\"1987/01/06\"");
console.log("Output: " + talkingCalendar("1987/01/06"));
console.log("\n");

console.log("Task 4\n======");
console.log("Input: total=209 | cash=1000 \nOutput: ");
console.log(calculateChange(209, 1000));