const API_URL = 'http://localhost:5146/api/peaje';
const API_PUBLICA = 'https://www.datos.gov.co/resource/7gj8-j6i3.json';

async function fetchPeajes() {
    try {
        const response = await fetch(API_URL);
        if (!response.ok) {
            throw new Error('Error en la respuesta de la API');
        }
        const data = await response.json();
        mostrarRegistrosPeajes(data); // Llamar función para mostrar los registros
    } catch (error) {
        console.error('Error al obtener los peajes:', error);
    }
}

function mostrarRegistrosPeajes(peajes) {
    const tableBody = document.getElementById('tableBody');

    tableBody.innerHTML = '';

    peajes.forEach(peaje => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td class="text-center">${peaje.nombrePeaje}</td>
            <td class="text-center">${peaje.placa}</td>
            <td class="text-center">${peaje.idCategoriaTarifa}</td>
            <td class="text-center">${peaje.fechaRegistro}</td>
            <td class="text-center">${peaje.valor}</td>
            <td class="text-center">
                <button type="button" class="btn btn-sm btn-warning" data-bs-toggle="modal" data-bs-target="#editModal" onclick="buscarRegistroPeaje(${peaje.id})">Editar</button>
                                
                <button class="btn btn-sm btn-danger ml-1" onclick="eliminarRegistroPeaje(${peaje.id})">Eliminar</button>
            </td>
        `;
        tableBody.appendChild(row);
    });
}

async function cargarOpcionesNombrePeaje() {
    try {
        const response = await fetch(API_PUBLICA);
        if (!response.ok) {
            throw new Error('Error en la respuesta de la API pública');
        }
        const data = await response.json();
        const selectNombrePeaje = document.getElementById('nombrePeaje');

        data.forEach(peaje => {
            const option = document.createElement('option');
            option.value = peaje.peaje;
            option.textContent = peaje.peaje;
            selectNombrePeaje.appendChild(option);
        });

    } catch (error) {
        console.error('Error al cargar opciones de nombre de peaje:', error);
    }
}

function cargarOpcionesCategoriaTarifa() {
    const selectCategoriaTarifa = document.getElementById('idCategoriaTarifa');
    selectCategoriaTarifa.innerHTML = '';

    const categorias = ['I', 'II', 'III', 'IV', 'V'];
    categorias.forEach(categoria => {
        const option = document.createElement('option');
        option.value = categoria;
        option.textContent = categoria;
        selectCategoriaTarifa.appendChild(option);
    });
}

async function autocompletarValor() {
    const nombrePeaje = document.getElementById('nombrePeaje').value;
    const idCategoriaTarifa = document.getElementById('idCategoriaTarifa').value;

    try {
        const response = await fetch(`${API_PUBLICA}?$q=${nombrePeaje}&idcategoriatarifa=${idCategoriaTarifa}`);
        if (!response.ok) {
            throw new Error('Error en la respuesta de la API externa');
        }
        const data = await response.json();
        if (data.length === 0) {
            throw new Error('No se encontró información del peaje');
        }
        const valor = data[0].valor;
        document.getElementById('valor').value = valor;
    } catch (error) {
        console.error('Error al autocompletar el valor del peaje:', error);
    }
}

document.getElementById('nombrePeajeActualizar').addEventListener('change', autocompletarValorActualizar);
document.getElementById('idCategoriaTarifaActualizar').addEventListener('change', autocompletarValorActualizar);

async function autocompletarValorActualizar() {
    const nombrePeaje = document.getElementById('nombrePeajeActualizar').value;
    const idCategoriaTarifa = document.getElementById('idCategoriaTarifaActualizar').value;

    try {
        const response = await fetch(`${API_PUBLICA}?$q=${nombrePeaje}&idcategoriatarifa=${idCategoriaTarifa}`);
        if (!response.ok) {
            throw new Error('Error en la respuesta de la API externa');
        }
        const data = await response.json();
        if (data.length === 0) {
            throw new Error('No se encontró información del peaje');
        }
        const valor = data[0].valor;
        document.getElementById('valorActualizar').value = valor;
    } catch (error) {
        console.error('Error al autocompletar el valor del peaje:', error);
    }
}

// Buscar y cargar datos del peaje para editar
async function buscarRegistroPeaje(id) {
    try {
        const response = await fetch(`${API_URL}/${id}`);
        if (!response.ok) {
            throw new Error('Error en la respuesta de la API');
        }
        const peaje = await response.json();

        document.getElementById('idActualizar').value = peaje.id;
        document.getElementById('placaActualizar').value = peaje.placa;
        document.getElementById('nombrePeajeActualizar').value = peaje.nombrePeaje;
        document.getElementById('idCategoriaTarifaActualizar').value = peaje.idCategoriaTarifa;

        // Autocompletar el valor del peaje al editar
        const nombrePeaje = peaje.nombrePeaje;
        const idCategoriaTarifa = peaje.idCategoriaTarifa;

        try {
            const responseValor = await fetch(`${API_PUBLICA}?$q=${nombrePeaje}&idcategoriatarifa=${idCategoriaTarifa}`);
            if (!responseValor.ok) {
                throw new Error('Error en la respuesta de la API externa');
            }
            const dataValor = await responseValor.json();
            if (dataValor.length === 0) {
                throw new Error('No se encontró información del peaje');
            }
            const valor = dataValor[0].valor;
            document.getElementById('valorActualizar').value = valor;
        } catch (error) {
            console.error('Error al autocompletar el valor del peaje:', error);
        }

        // Tipo de dato compatible con la BD
        const fechaRegistro = new Date(peaje.fechaRegistro).toISOString().split('T')[0];
        document.getElementById('fechaRegistroActualizar').value = fechaRegistro;

    } catch (error) {
        console.error('Error al obtener el registro del peaje:', error);
    }
}


async function agregarRegistroPeaje(event) {
    event.preventDefault(); // Evitar el envío del formulario por defecto

    const placa = document.getElementById('placa').value;
    const nombrePeaje = document.getElementById('nombrePeaje').value;
    const idCategoriaTarifa = document.getElementById('idCategoriaTarifa').value;
    const fechaRegistro = document.getElementById('fechaRegistro').value;
    const valor = document.getElementById('valor').value; 

    const nuevoPeaje = {
        placa: placa,
        nombrePeaje: nombrePeaje,
        idCategoriaTarifa: idCategoriaTarifa,
        fechaRegistro: fechaRegistro,
        valor: valor
    };

    try {
        const responseApi = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(nuevoPeaje)
        });

        if (!responseApi.ok) {
            console.log(nuevoPeaje);
            throw new Error('Error al registrar peaje en la API');
        }

        document.getElementById('formInsertar').reset();
        $('#registroModal').modal('hide');
        $('body').removeClass('modal-open');
        $('.modal-backdrop').remove();
        fetchPeajes();

    } catch (error) {
        console.error('Error al agregar registro de peaje:', error);
        alert('Error al agregar registro de peaje');
    }
}

async function actualizarRegistroPeaje(event) {
    event.preventDefault(); // Evitar el envío del formulario por defecto

    const idActualizar = document.getElementById('idActualizar').value;
    const placa = document.getElementById('placaActualizar').value;
    const nombrePeaje = document.getElementById('nombrePeajeActualizar').value;
    const idCategoriaTarifa = document.getElementById('idCategoriaTarifaActualizar').value;
    const fechaRegistro = document.getElementById('fechaRegistroActualizar').value;
    const valor = document.getElementById('valorActualizar').value;

    const actualizarPeaje = {
        id: idActualizar,
        placa: placa,
        nombrePeaje: nombrePeaje,
        idCategoriaTarifa: idCategoriaTarifa,
        fechaRegistro: fechaRegistro,
        valor: valor
    };

    try {
        const response = await fetch(`${API_URL}/${idActualizar}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(actualizarPeaje)
        });

        if (!response.ok) {
            throw new Error('Error al actualizar el registro del peaje');
        }

        $('#editModal').modal('hide');
        $('body').removeClass('modal-open');
        $('.modal-backdrop').remove();
        fetchPeajes();

    } catch (error) {
        console.error('Error al actualizar el registro del peaje:', error);
        alert('Error al actualizar el registro del peaje');
    }
}

async function eliminarRegistroPeaje(id) {
    if (!confirm('¿Estás seguro de eliminar este registro?')) {
        return;
    }

    try {
        const response = await fetch(`${API_URL}/${id}`, {
            method: 'DELETE'
        });

        if (!response.ok) {
            throw new Error('Error al eliminar el registro del peaje');
        }

        fetchPeajes();

    } catch (error) {
        console.error('Error al eliminar el registro del peaje:', error);
        alert('Error al eliminar el registro del peaje');
    }
}


document.addEventListener('DOMContentLoaded', () => {
    fetchPeajes();
    cargarOpcionesNombrePeaje();
    cargarOpcionesCategoriaTarifa();

    document.getElementById('nombrePeaje').addEventListener('change', autocompletarValor);
    document.getElementById('idCategoriaTarifa').addEventListener('change', autocompletarValor);
});

document.getElementById('formInsertar').addEventListener('submit', agregarRegistroPeaje);
document.getElementById('editForm').addEventListener('submit', actualizarRegistroPeaje);
document.getElementById('editForm').addEventListener('submit', actualizarRegistroPeaje);

