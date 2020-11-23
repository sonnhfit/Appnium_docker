const driver = require("webdriverio");
const assert = require("assert");

const sleep = (ms) => {
    return new Promise((resolve) => setTimeout(resolve, ms));
};

// Replace these settings
const opts = {
    path: "/wd/hub",
    port: 4723,
    capabilities: {
        platformName: "Android",
        platformVersion: "10",
        udid: "R58N53KSENR",
    },
};

async function main() {
    const client = await driver.remote(opts);

    // Get element using xpath
    // const searchButton = await client.$('//android.widget.ImageView[@content-desc="Tìm kiếm"]');

    // await searchButton.click();

    // await sleep(1000);

    // Get element using resource id
    // const searchInput = await client.$(
    //     'android=new UiSelector().resourceId("com.google.android.youtube:id/search_edit_text")'
    // );

    // await searchInput.setValue("son nguyen snc");

    // const searchInputValue = await searchInput.getText();

    // assert.equal(searchInputValue, "son nguyen snc");

    // await sleep(3000);

    await client.deleteSession();
}

main();
