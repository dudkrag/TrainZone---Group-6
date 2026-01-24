
# TrainZone

TrainZone is a mobile health application designed to support football players in understanding their training intensity and workload through real-time physiological feedback. The application integrates a **Movesense wearable sensor** with a **Flutter-based mobile app** to collect heart rate, ECG, and positional data during training sessions and matches. Collected data is translated into intuitive training intensity zones and stored locally for post-session analysis and reflection.

The system is designed to be **player-centered**, allowing athletes to access, review, and control their own physiological and positional data. In addition, summarized training information can be selectively shared with a coach to support planning and performance evaluation.

---

## Technologies and Libraries

The application is implemented using **Flutter** and **Dart** and targets **Android devices**. Sensor communication is handled using the **Movesense Plus** library. Permissions and system access are managed using Flutter plugins.

Main libraries used:

* `movesense_plus` – communication with the Movesense wearable sensor
* `permission_handler` – handling Bluetooth, location, and system permissions
* `vibration` – real-time haptic feedback
* `geolocator` – GPS-based positional data
* `sembast` – local database for data storage
* `path_provider` and `path` – file system access

Training data can be exported as JSON files and visualized offline using **Python**, with libraries such as **NumPy** and **Matplotlib**.

---

## Project Structure

The repository is structured as follows:

* **lib/**

  * **model/** – Domain models including users, training sessions, training zones, sensor, storage.
  * **view/** – User interface components, containing only UI-related code
  * **viewmodel/** – ViewModels implementing application logic and state management using ChangeNotifier

* **python/**

  * Scripts for plotting and analyzing exported training zone data


## UX Design

TrainZone consists of a **role-based flow** supporting both Players and Coaches. Users log in via a list-based selection screen where new profiles can also be created.

For players, the application provides a home screen with an overview of sensor connection status and metrics from the most recent training session. During training, real-time feedback is primarily delivered through **phone vibration**, allowing the player to remain focused on gameplay. Visual feedback is also provided for transparency and post-session review.

Coaches can access historical training data of players who have granted permission, enabling an overview of player workload and supporting planning of future training sessions and matches.

* **Print screen of final wireflow**

  <img width="8050" height="5602" alt="Wireframe Final" src="https://github.com/user-attachments/assets/48e52937-535f-4cc0-8bbc-4c005db89a07" />

  link to Figma: https://www.figma.com/design/4UgHvgL87v7E80QsewXXpT/TrainZone?node-id=0-1&t=0b47lQVC42A3gtbk-1



## Notes

* The application is a **prototype** developed for academic purposes.
* The system has been tested on **Android devices** and has not been evaluated on iOS.
* The project does not provide medical diagnosis and is intended for training support and reflection only. 
