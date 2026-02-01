const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function captureSlides() {
  const slidesDir = path.join(__dirname, 'slides');
  const outputDir = path.join(__dirname, 'screenshots');
  
  // Get all slide files sorted by number
  const files = fs.readdirSync(slidesDir)
    .filter(f => f.endsWith('.html'))
    .sort((a, b) => {
      const numA = parseInt(a.match(/\d+/)[0]);
      const numB = parseInt(b.match(/\d+/)[0]);
      return numA - numB;
    });
  
  console.log(`Found ${files.length} slides to capture`);
  
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1920, height: 1080 });
  
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const filePath = `file://${path.join(slidesDir, file)}`;
    const outputPath = path.join(outputDir, file.replace('.html', '.png'));
    
    console.log(`Capturing ${i + 1}/${files.length}: ${file}`);
    
    await page.goto(filePath, { waitUntil: 'networkidle' });
    await page.screenshot({ path: outputPath, type: 'png' });
  }
  
  await browser.close();
  console.log('All slides captured!');
}

captureSlides().catch(console.error);
