<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Ahan-Amrit</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/tesseract.js@4.0.2/dist/tesseract.min.js"></script>
  <style>
    :root {
      --bg: #0d0d0d;
      --text: #f2f2f2;
      --muted: #999;
      --accent: #9b6bf5;
      --accent-light: #c59bff;
    }

    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    html, body {
      height: 100%;
      font-family: 'Inter', sans-serif;
      background-color: var(--bg);
      color: var(--text);
    }

    body {
      display: flex;
      flex-direction: column;
      overflow-x: hidden;
    }

    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 24px 5%;
      z-index: 2;
    }

    .logo {
      font-weight: 800;
      font-size: 22px;
    }

    .logo span {
      display: block;
      font-size: 12px;
      font-weight: 400;
      color: var(--muted);
    }

    .btn {
      background: linear-gradient(135deg, var(--accent), var(--accent-light));
      color: white;
      border: none;
      border-radius: 30px;
      padding: 10px 22px;
      font-weight: 600;
      cursor: pointer;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .btn:hover {
      transform: scale(1.05);
      box-shadow: 0 0 10px var(--accent);
    }

    main {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      text-align: center;
      padding: 60px 20px;
      position: relative;
      z-index: 2;
    }

    h1 {
      font-size: 48px;
      font-weight: 800;
      line-height: 1.2;
      margin-bottom: 20px;
    }

    .highlight {
      color: var(--accent);
      
      display: inline-block;
      padding-bottom: 4px;
    }

    p {
      font-size: 18px;
      color: var(--muted);
      max-width: 600px;
      margin: 0 auto 30px;
      line-height: 1.6;
    }

    .bg-pattern {
      position: absolute;
      inset: 0;
      background: url('https://www.transparenttextures.com/patterns/dark-matter.png');
      opacity: 0.05;
      z-index: 0;
    }

    .sphere {
      position: absolute;
      top: 15%;
      right: 5%;
      width: 250px;
      height: 250px;
      background: url('https://upload.wikimedia.org/wikipedia/commons/e/ea/Wireframe_3D_Torus_Knot.svg') no-repeat center;
      background-size: contain;
      opacity: 0.35;
      animation: floaty 5s ease-in-out infinite;
      z-index: 0;
    }

    #imageInput {
      margin-top: 20px;
      color: var(--text);
    }

    #resultText {
      margin-top: 20px;
      max-width: 600px;
      color: var(--text);
      font-size: 16px;
    }

    @keyframes floaty {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(-20px); }
    }

    @media (max-width: 768px) {
      h1 {
        font-size: 36px;
      }

      .sphere {
        display: none;
      }

      .btn {
        font-size: 14px;
        padding: 10px 20px;
      }
    }
    hr {
  border: none;
  height: 4px;
  width: 80%;
  margin: 30px auto; /* centers it horizontally */
  display: block;
  background: linear-gradient(to right, var(--accent), var(--accent-light)); /* Cool turquoise gradient */
  border-radius: 999px;
  opacity: 0.9;
  animation: fadeIn 1s ease-in-out;
}

@keyframes fadeIn {
  0% {
    opacity: 0;
    transform: scaleX(0.5);
  }
  100% {
    opacity: 0.9;
    transform: scaleX(1);
  }
}
      footer {
      text-align: center;
      padding: 20px;
      font-size: 14px;
      color: var(--muted);
    }
  </style>
</head>
<body>
  <div class="bg-pattern"></div>
  <div class="sphere"></div>

  <header>
    <div class="logo">Ahan-Amrit <span>by Bikram Sadhukhan</span></div>
    <button onclick="window.location.href='contact.html'" class="btn">Get in Touch</button>
  </header>

  <main>
    <h1><span class="highlight">Ahan-Amrit</span> (AI enabled Food Label Scanner)</h1><hr><br><h2>Know What You're Really Eating</h2><br>
    <p>Snap a photo of any food label and instantly detect hidden chemicals, preservatives, or additives. Make smarter, healthier food choices effortlessly.</p>

    <input type="file" id="imageInput" accept="image/*" class="btn" />
    <div id="resultText">Upload a food label to scan its content.</div>
	<table id="resultTable" style="margin-top: 20px; border-collapse: collapse; display: none;">
	  <thead>
	    <tr>
	      <th style="border: 1px solid #999; padding: 10px; color: var(--accent-light);">Ingredient</th>
	    </tr>
	  </thead>
	  <tbody id="tableBody"></tbody>
	</table>

  </main>
  
  <footer>
    2025 Ahan-Amrit. All rights reserved.
  </footer>

  <script>
const imageInput = document.getElementById("imageInput");
const resultText = document.getElementById("resultText");
const table = document.getElementById("resultTable");
const tableBody = document.getElementById("tableBody");

const OPENROUTER_API_KEY = "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";

imageInput.addEventListener("change", async () => {
  const file = imageInput.files[0];
  if (!file) return;

  resultText.textContent = "Scanning label... Please wait...";
  table.style.display = "none";
  tableBody.innerHTML = "";

  const reader = new FileReader();
  reader.onload = async () => {
    try {
      const { data: { text } } = await Tesseract.recognize(
        reader.result,
        'eng',
        { logger: m => console.log(m) }
      );

      resultText.textContent = "Text scanned successfully!";
      const items = text
        .split(',')
        .map(item => item.trim())
        .filter(item => item.length > 0);
      const redirectButton = document.createElement("button");
      redirectButton.textContent = "Get Detailed Analysis";
      redirectButton.className = "btn";
      redirectButton.style.marginTop = "20px";
      redirectButton.onclick = () => {
        window.location.href = "http://localhost/test/fetch_ingredients.php"; // Change to your desired page
      };


      if (items.length > 0) {
        table.style.display = "table";
        for (const item of items) {
          const effect = await getHealthEffect(item);

          // Send ingredient + effect to your Java Servlet
          fetch('http://localhost:8080/demo/food', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
              ingredient: item,
              effect: effect
            })
          })
          .then(res => res.text())
          .then(msg => console.log("Server:", msg))
          .catch(err => console.error("DB Error:", err));

          const row = document.createElement("tr");

          const nameCell = document.createElement("td");
          nameCell.style.border = "1px solid #999";
          nameCell.style.padding = "10px";
          nameCell.textContent = item;

          

          row.appendChild(nameCell);
          table.parentNode.appendChild(redirectButton);
          tableBody.appendChild(row);
        }
      } else {
        resultText.textContent = "â ï¸ No valid items found.";
      }
    } catch (error) {
      resultText.textContent = "â Error reading image. Try again.";
      console.error(error);
    }
  };
  reader.readAsDataURL(file);
});

async function getHealthEffect(ingredient) {
  try {
    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${OPENROUTER_API_KEY}`,
      },
      body: JSON.stringify({
        model: "google/gemini-pro",
        messages: [
          {
            role: "user",
            content: `Give a one-line summary of health effects (positive or negative) of the food ingredient: "${ingredient}". Keep it simple.`
          }
        ]
      }),
    });

    const data = await response.json();
    console.log("Gemini response:", data);

    const reply = data?.choices?.[0]?.message?.content;
    return reply || "No info found.";
  } catch (error) {
    console.error("Gemini API error:", error);
    return "Error fetching health info.";
  }
}
</script>



</body>
</html>
