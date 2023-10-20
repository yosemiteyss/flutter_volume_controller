#include <sstream>
#include "include/flutter_volume_controller/output_device.h"

namespace flutter_volume_controller {
	OutputDevice::OutputDevice(const std::string& id, const std::string& name, bool volume_control)
		: id(id), name(name), volume_control(volume_control) {}

	const std::string OutputDevice::ToJson() const {
		std::stringstream ss;
		ss << "{ \"id\": \"" << this->id << "\", ";
		ss << "\"name\": \"" << this->name << "\", ";
		ss << "\"volumeControl\": " << std::boolalpha << this->volume_control << " }";
		return ss.str();
	}

	const std::string& OutputDevice::GetId() const {
		return id;
	}

	const std::string& OutputDevice::GetName() const {
		return name;
	}

	bool OutputDevice::VolumeControl() const {
		return volume_control;
	}

	std::string OutputDevice::ToJsonList(std::vector<OutputDevice> devices) {
		std::string json = "[";
		for (size_t i = 0; i < devices.size(); ++i) {
			json += devices[i].ToJson();
			if (i < devices.size() - 1) {
				json += ",";
			}
		}
		json += "]";
		return json;
	}

	bool OutputDevice::operator==(const OutputDevice& other) const {
		return other.name.compare(this->name);
	}
}
