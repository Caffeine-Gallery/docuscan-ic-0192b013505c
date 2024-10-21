import { backend } from 'declarations/backend';

const fileInput = document.getElementById('fileInput');
const uploadButton = document.getElementById('uploadButton');
const resultsDiv = document.getElementById('results');
const downloadCSVButton = document.getElementById('downloadCSV');

uploadButton.addEventListener('click', async () => {
  const files = fileInput.files;
  if (files.length === 0) {
    alert('Please select at least one file.');
    return;
  }

  resultsDiv.innerHTML = 'Processing...';

  for (const file of files) {
    const reader = new FileReader();
    reader.onload = async (e) => {
      const arrayBuffer = e.target.result;
      const blob = new Blob([new Uint8Array(arrayBuffer)]);
      const id = await backend.uploadImage(file.name, blob);
      const extractedData = await backend.getExtractedData(id);
      displayResult(extractedData);
    };
    reader.readAsArrayBuffer(file);
  }
});

function displayResult(data) {
  if (!data) {
    resultsDiv.innerHTML += '<p>Error processing image.</p>';
    return;
  }

  const table = document.createElement('table');
  table.innerHTML = `
    <tr><th>Field</th><th>Value</th></tr>
    ${Object.entries(data).map(([key, value]) => `
      <tr>
        <td>${key}</td>
        <td>${value !== null ? value : 'N/A'}</td>
      </tr>
    `).join('')}
  `;
  resultsDiv.appendChild(table);
}

downloadCSVButton.addEventListener('click', async () => {
  const csv = await backend.generateCSV();
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'extracted_data.csv';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
});
