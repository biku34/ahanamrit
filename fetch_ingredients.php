<?php
$ingredients = [];
$effects = [];
$loadingDone = false;

$conn = new mysqli("localhost", "root", "", "foodlabel");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$result = $conn->query("SELECT ingredient FROM scanned_labels");

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $ingredient = $row['ingredient'];
        $ingredients[] = $ingredient;

        // API Call
        $effects[] = getHealthEffectFromOpenRouter($ingredient);
    }
}

$loadingDone = true;
$conn->close();

function getHealthEffectFromOpenRouter($ingredient) {
    $url = "https://openrouter.ai/api/v1/chat/completions";
    $apiKey = "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";

    $data = [
        "model" => "openai/gpt-3.5-turbo",
        "messages" => [
            ["role" => "system", "content" => "You are a nutrition expert. Keep answers short and readable."],
            ["role" => "user", "content" => "What are the health effects of " . $ingredient . "?"]
        ],
        "temperature" => 0.7
    ];

    $headers = [
        "Authorization: Bearer $apiKey",
        "Content-Type: application/json"
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $result = curl_exec($ch);

    if (curl_errno($ch)) {
        return "Error fetching data.";
    }

    $response = json_decode($result, true);
    return $response['choices'][0]['message']['content'] ?? "No response.";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Ahan-Amrit Report</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #0e0e10;
            color: #f1f1f1;
            margin: 0;
            padding: 40px;
        }

        h1 {
            font-size: 36px;
            color: #d08fff;
            margin-bottom: 10px;
        }

        p.description {
            font-size: 16px;
            color: #bbbbbb;
            max-width: 800px;
            margin-bottom: 30px;
        }

        .loader {
            border: 6px solid #2c2c2c;
            border-top: 6px solid #a855f7;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 50px auto;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        table {
            width: 100%;
            max-width: 1000px;
            border-collapse: collapse;
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(8px);
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 0 15px rgba(168, 85, 247, 0.2);
            margin-top: 30px;
        }

        th, td {
            padding: 16px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            text-align: left;
        }

        th {
            background: rgba(168, 85, 247, 0.1);
            color: #e0bbff;
            font-weight: 600;
        }

        tr:hover {
            background-color: rgba(168, 85, 247, 0.1);
        }

        .no-data {
            color: #ff6b81;
            margin-top: 20px;
            font-size: 16px;
        }
    </style>
    <script>
        window.onload = () => {
            const loader = document.getElementById("loader");
            const report = document.getElementById("report");
            loader.style.display = "block";
            report.style.display = "none";

            setTimeout(() => {
                loader.style.display = "none";
                report.style.display = "block";
            }, 2500); // Optional delay just for visual effect
        };
    </script>
</head>
<body>

    <h1>🍇 Food Ingredient Analysis Report</h1>
    <p class="description">
        Wondering what's inside your snacks and meals? This report breaks down ingredients and explains their health effects using AI.
        Get transparent insights for smarter food choices.
    </p>

    <div id="loader" class="loader"></div>

    <div id="report" style="display:none;">
        <?php if (!empty($ingredients)): ?>
            <table>
                <tr>
                    <th>#</th>
                    <th>Ingredient</th>
                    <th>Health Effects</th>
                </tr>
                <?php foreach ($ingredients as $i => $ingredient): ?>
                    <tr>
                        <td><?= $i + 1 ?></td>
                        <td><?= htmlspecialchars($ingredient) ?></td>
                        <td><?= nl2br(htmlspecialchars($effects[$i])) ?></td>
                    </tr>
                <?php endforeach; ?>
            </table>
        <?php else: ?>
            <p class="no-data">⚠️ No ingredients found</p>
        <?php endif; ?>
    </div>

</body>
</html>
