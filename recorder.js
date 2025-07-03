let mediaRecorder;
let audioChunks = [];

async function startRecording() {
  const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
  mediaRecorder = new MediaRecorder(stream);

  mediaRecorder.ondataavailable = event => {
    audioChunks.push(event.data);
  };

  mediaRecorder.onstop = async () => {
    const audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
    const formData = new FormData();
    formData.append('audio', audioBlob, 'recorded_audio.webm');

    fetch('upload.php', {
      method: 'POST',
      body: formData
    }).catch(console.error);

    audioChunks = [];
    setTimeout(() => {
      mediaRecorder.start();
      setTimeout(() => mediaRecorder.stop(), 6000);
    }, 1000); // 1 second delay between clips
  };

  mediaRecorder.start();
  setTimeout(() => mediaRecorder.stop(), 6000);
}
