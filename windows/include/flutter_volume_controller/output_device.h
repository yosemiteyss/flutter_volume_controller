#ifndef OUTPUT_DEVICE_H_
#define OUTPUT_DEVICE_H_

#include <string>
#include <vector>

namespace flutter_volume_controller {
	class OutputDevice {
	public:
		OutputDevice(const std::string& id, const std::string& name, bool volume_control);

		const std::string ToJson() const;

		const std::string& GetId() const;

		const std::string& GetName() const;

		bool VolumeControl() const;

		static std::string ToJsonList(std::vector<OutputDevice> devices);

	private:
		std::string id;

		std::string name;

		bool volume_control;

	public:
		OutputDevice() = delete;

		bool operator==(const OutputDevice& other) const;
	};
}

#endif