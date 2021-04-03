/* FEATURE 1 linkedin Button to site */
document.getElementById("linkedinButton").onclick = function () {
    location.href = "https://linkedin.com/in/jhy03/";
};

/* FEATURE 2 email Button to site */
document.getElementById("emailButton").onclick = function () {
    location.href = "mailto:jhyoon03@berkeley.edu";
};

/* FEATURE ATTEMPT change fruit to respective color */
// let MyappleButton = document.getElementById("appleButton");
// let Mycontainer3 = document.getElementById("container3");
// function changetoRed() {
//     container3.color("red");
// }
// MyappleButton.onclick = changetoRed;


/*  FEATURE 3 CAROUSEL */
/* Width of each carousel image, in pixels */
let carouselWidth = 1300; 

/* elements */
let prevButton = document.getElementById("button-previous");
let nextButton = document.getElementById("button-next");
let imageRow = document.getElementById("carousel-image-row");
let logoButton = document.getElementById("logo");
// let wow1Button = document.getElementById("wow1");

/* keep track of image */
let imageNum = 0;

/* showNextImage function shifts image row to left */
function showNextImage() {
	 imageNum = imageNum + 1;
	 checkControls();
	let shift = -1*imageNum*carouselWidth;
	imageRow.style.left = shift + "px"; 

}

/* change onclick property for next button */
nextButton.onclick = showNextImage;


/* showPrevImage function shifts image row to right */
function showPrevImage() {
	imageNum = imageNum - 1;
	checkControls();
	let shift = (-1* imageNum * carouselWidth) + "px";
	imageRow.style.left = shift; 
}

/* change onclick property for prev button */
prevButton.onclick = showPrevImage;


/* total number of images */
let totalImages = document.getElementsByClassName("carousel-image").length;


function checkControls() {
	if (imageNum == 0) {
		prevButton.classList.add("hidden");
	}
	else if (prevButton.classList.contains("hidden")) {
		prevButton.classList.remove("hidden");
	}
	
	if (imageNum == 35) {
		nextButton.classList.add("hidden");
	}
	else if (nextButton.classList.contains("hidden")) {
		nextButton.classList.remove("hidden");
	}
}
