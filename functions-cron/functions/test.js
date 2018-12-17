const admin = require("firebase-admin");
const cheerio = require("cheerio");
const puppeteer = require("puppeteer");
admin.initializeApp({
  credential: admin.credential.applicationDefault()
});

async function run() {
  var html = await getHtml();
  let $ = cheerio.load(html);
  $("span.selected-tag").each(function(i, element) {
    console.log($(this).text());
  });
}

function getHtml() {
  return new Promise(async function(resolve) {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto("https://new.dineoncampus.com/Northeastern/menus");
    await page.waitFor("div.dropdown-toggle.clearfix");

    await page.click("div.dropdown-toggle.clearfix");
    // await page.click(
    //   "#select2-div.dropdown-toggle.clearfix-results > li:nth-child(2)"
    // );
    await page.focus("div.dropdown.v-select");
    await page.type("le");
    await page.type(String.fromCharCode(13));
    await page.waitFor("span.selected-tag");
    await page.screenshot({ path: "example.png" });

    let html = await page.evaluate(() => document.body.innerHTML);
    //   console.log(html);
    await browser.close();
    resolve(html);
  });
}

run();
