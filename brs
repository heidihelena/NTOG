<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Brief Resilience Scale (BRS)</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: center;
        }
        th {
            background-color: #f2f2f2;
        }
        label {
            display: block;
            margin: 10px 0 5px;
        }
    </style>
</head>
<body>

<h2>Brief Resilience Scale (BRS)</h2>

<p>Please respond to each item by marking <strong>one box per row</strong></p>

<form id="brsForm">
    <table>
        <thead>
            <tr>
                <th>Item</th>
                <th>Statement</th>
                <th>Strongly Disagree (1)</th>
                <th>Disagree (2)</th>
                <th>Neutral (3)</th>
                <th>Agree (4)</th>
                <th>Strongly Agree (5)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>BRS 1</td>
                <td>I tend to bounce back quickly after hard times</td>
                <td><input type="radio" name="brs1" value="1" required></td>
                <td><input type="radio" name="brs1" value="2"></td>
                <td><input type="radio" name="brs1" value="3"></td>
                <td><input type="radio" name="brs1" value="4"></td>
                <td><input type="radio" name="brs1" value="5"></td>
            </tr>
            <tr>
                <td>BRS 2</td>
                <td>I have a hard time making it through stressful events</td>
                <td><input type="radio" name="brs2" value="5" required></td>
                <td><input type="radio" name="brs2" value="4"></td>
                <td><input type="radio" name="brs2" value="3"></td>
                <td><input type="radio" name="brs2" value="2"></td>
                <td><input type="radio" name="brs2" value="1"></td>
            </tr>
            <tr>
                <td>BRS 3</td>
                <td>It does not take me long to recover from a stressful event</td>
                <td><input type="radio" name="brs3" value="1" required></td>
                <td><input type="radio" name="brs3" value="2"></td>
                <td><input type="radio" name="brs3" value="3"></td>
                <td><input type="radio" name="brs3" value="4"></td>
                <td><input type="radio" name="brs3" value="5"></td>
            </tr>
            <tr>
                <td>BRS 4</td>
                <td>It is hard for me to snap back when something bad happens</td>
                <td><input type="radio" name="brs4" value="5" required></td>
                <td><input type="radio" name="brs4" value="4"></td>
                <td><input type="radio" name="brs4" value="3"></td>
                <td><input type="radio" name="brs4" value="2"></td>
                <td><input type="radio" name="brs4" value="1"></td>
            </tr>
            <tr>
                <td>BRS 5</td>
                <td>I usually come through difficult times with little trouble</td>
                <td><input type="radio" name="brs5" value="1" required></td>
                <td><input type="radio" name="brs5" value="2"></td>
                <td><input type="radio" name="brs5" value="3"></td>
                <td><input type="radio" name="brs5" value="4"></td>
                <td><input type="radio" name="brs5" value="5"></td>
            </tr>
            <tr>
                <td>BRS 6</td>
                <td>I tend to take a long time to get over set-backs in my life</td>
                <td><input type="radio" name="brs6" value="5" required></td>
                <td><input type="radio" name="brs6" value="4"></td>
                <td><input type="radio" name="brs6" value="3"></td>
                <td><input type="radio" name="brs6" value="2"></td>
                <td><input type="radio" name="brs6" value="1"></td>
            </tr>
        </tbody>
    </table>

    <label for="score">My score:</label>
    <input type="text" id="score" readonly>

    <button type="button" onclick="calculateScore()">Calculate Score</button>
</form>

<script>
    function calculateScore() {
        const form = document.forms["brsForm"];
        let totalScore = 0;
        let itemCount = 0;

        for (let i = 1; i <= 6; i++) {
            const selectedOption = form["brs" + i].value;
            if (selectedOption) {
                totalScore += parseInt(selectedOption);
                itemCount++;
            }
        }

        const averageScore = itemCount > 0 ? (totalScore / itemCount).toFixed(2) : 0;
        document.getElementById("score").value = averageScore;
    }
</script>

</body>
</html>
