  let html5QrCode;
  let isScannerRunning = false;

  function populateCameraList(cameras) {
      const cameraList = document.getElementById('cameraList');
      cameraList.innerHTML = '';
      cameras.forEach((camera, index) => {
          const option = document.createElement('option');
          option.value = camera.id;
          option.innerText = camera.label || `Camera ${index + 1}`;
          cameraList.appendChild(option);
      });
  }

  async function startCamera(cameraId) {
      const config = {
          fps: 30,
          qrbox: {
              width: 200,
              height: 200
          },
          rememberLastUsedCamera: true,
          showTorchButtonIfSupported: true,
          showZoomSliderIfSupported: true
      };
      const qrCodeSuccessCallback = (decodedText, decodedResult) => {
          html5QrCode.stop();
          window.parent.postMessage(decodedText, "*");
          if (window.chrome.webview != "undefined") {
              var param = {
                  "methodName": "successCallback",
                  "data": decodedText
              }
              window.chrome.webview.postMessage(param);
          }
      };
      if (isScannerRunning) {
          await html5QrCode.stop();
          isScannerRunning = false;
      }
      html5QrCode.start({
              deviceId: {
                  exact: cameraId
              }
          }, config, qrCodeSuccessCallback)
          .then(() => {
              isScannerRunning = true;
          })
          .catch(err => {
              console.error(`Error starting camera with ID ${cameraId}: ${err}`);
              isScannerRunning = false;
          });
  }

  function changeCamera(cameraId) {
      if (cameraId) {
          localStorage.setItem('selectedCameraId', cameraId);
          document.getElementById('cameraSelector').style.display = 'none';
          startCamera(cameraId);
      }
  }

  function toggleFlash(element) {
      if (html5QrCode && isScannerRunning) {
          if (element.checked) {
              html5QrCode.turnOnFlash()
                  .then(() => console.log("Flash turned on!"))
                  .catch(err => console.error("Error turning on flash.", err));
          } else {
              html5QrCode.turnOffFlash()
                  .then(() => console.log("Flash turned off!"))
                  .catch(err => console.error("Error turning off flash.", err));
          }
      }
  }

  document.getElementById('openSettings').addEventListener('click', function(event) {
      event.stopPropagation();
      const cameraSelector = document.getElementById('cameraSelector');
      cameraSelector.style.display = cameraSelector.style.display === 'none' ? 'block' : 'none';
  });

  document.addEventListener('click', function() {
      const cameraSelector = document.getElementById('cameraSelector');
      if (cameraSelector.style.display === 'block') {
          cameraSelector.style.display = 'none';
      }
  });

  document.getElementById('cameraSelector').addEventListener('click', function(event) {
      event.stopPropagation();
  });

  window.onload = () => {
      html5QrCode = new Html5Qrcode("reader");
      Html5Qrcode.getCameras().then(devices => {
          if (devices && devices.length) {
              document.getElementById('reader').style.display = 'block';
              document.getElementById('openSettings').style.display = 'block';

              populateCameraList(devices);

              const savedCameraId = localStorage.getItem('selectedCameraId');
              if (savedCameraId && devices.some(device => device.id === savedCameraId)) {
                  startCamera(savedCameraId);
                  document.getElementById('cameraList').value = savedCameraId;
              } else {

                  startCamera(devices[0].id);
                  document.getElementById('cameraList').value = devices[0].id;
              }
          } else {
              document.getElementById('noCameraAvailable').style.display = 'block';
          }
      }).catch(err => {
          console.error(`Errore nel recuperare le fotocamere: ${err}`);
          document.getElementById('openSettings').style.display = 'none';
          switch (err.name) {
              case "NotAllowedError":
                  document.getElementById('noCameraPermission').style.display = 'block';
                  break;
              case "NotFoundError":
                  document.getElementById('noCameraAvailable').style.display = 'block';
                  break;
              case "NotReadableError":
                  document.getElementById('cameraInUse').style.display = 'block';
                  break;
              default:
                  console.error(`Errore non gestito: ${err.name}`);
          }
      });
  };