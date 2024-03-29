<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Laravel EventStream</title>

        <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tailwindcss/dist/tailwind.min.css">

    </head>
    <body>
        <div class="container w-full mx-auto">
            <div class="w-full px-4 md:px-0 md:mt-8 mb-16 text-gray-800 leading-normal">
                <div class="flex flex-row flex-wrap flex-grow mt-2">
                    <div class="w-full p-3">
                        <div class="bg-white border rounded shadow">
                            <div class="border-b p-3">
                                <h5 class="font-bold uppercase text-gray-600">Notifications</h5>
                            </div>
                            <div class="p-5 overflow-scroll" style="height:500px">
                                <table class="w-full p-5 text-gray-700">
                                    <thead>
                                        <tr>
                                            <th class="text-left text-blue-900">Notifications in the last 60 seconds</th>
                                        </tr>
                                    </thead>
                                    <tbody id="allNotifications">
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </body>
    <script>
        const eventSource = new EventSource('http://localhost:8000/notifications');

        eventSource.onmessage = function(event) {
            if (event.data.includes('latest_user')) {
                let value = JSON.parse(event.data)
                const newElement = document.createElement("tr");
                const eventList = document.getElementById("allNotifications");
                newElement.textContent = "message: " + event.data;
                //newElement.textContent = "ping at " + time;
                eventList.prepend(newElement);
            }
        }


    </script>
</html>